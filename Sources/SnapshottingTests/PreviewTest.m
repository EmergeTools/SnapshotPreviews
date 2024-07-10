#import "PreviewTest.h"
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

@interface PreviewTest()
@property (nonatomic, strong) NSMutableArray<NSString *> *dynamicTestSelectors;
@end

@implementation PreviewTest

static NSString *resultPath;
static NSMutableArray<NSString *> *typeNames;
static NSMutableArray<NSNumber *> *previewIds;

NSString* getDylibPath(NSString* dylibName) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *imagePath = _dyld_get_image_name(i);
        NSString *imagePathStr = [NSString stringWithUTF8String:imagePath];
        if ([imagePathStr.lastPathComponent isEqualToString:dylibName]) {
            return imagePathStr;
        }
    }
    return nil;
}

+ (NSArray<NSInvocation *> *)testInvocations {
  PreviewTest *dynamicTest = [[self alloc] init];
    [dynamicTest generateSnapshots];

    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];
    for (NSString *testName in dynamicTest.dynamicTestSelectors) {
        SEL selector = NSSelectorFromString(testName);
        NSMethodSignature *signature = [dynamicTest methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = selector;
        [invocations addObject:invocation];
    }
    return invocations;
}

- (XCUIApplication *)getApp {
  return nil;
}

- (NSArray<NSString *> *)snapshotPreviews {
  return NULL;
}

- (NSArray<NSString *> *)excludedSnapshotPreviews {
  return NULL;
}

- (BOOL)enableAccessibilityAudit {
  return YES;
}

- (XCUIAccessibilityAuditType)auditType API_AVAILABLE(ios(17.0)) {
  return XCUIAccessibilityAuditTypeAll;
}

- (BOOL)handleIssue:(XCUIAccessibilityAuditIssue *)issue API_AVAILABLE(ios(17.0)) {
  return NO;
}

- (void)generateSnapshots {

  XCUIApplication *app = [self getApp];

  if (app == nil) {
    return;
  }

  NSString *path = getDylibPath(@"Snapshotting");
  if (!path) {
    NSLog(@"Snapshotting dylib not found, ensure it is a dependency of your test target.");
  }
  assert(path != nil);

  NSMutableDictionary *launchEnvironment = [app.launchEnvironment mutableCopy];
  launchEnvironment[@"EMERGE_IS_RUNNING_FOR_SNAPSHOTS"] = @"1";
  launchEnvironment[@"DYLD_INSERT_LIBRARIES"] = path;
  NSArray *previews = [self snapshotPreviews];
  if (previews) {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:previews options:nil error:nil];
    launchEnvironment[@"SNAPSHOT_PREVIEWS"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
    
  NSArray *excludedPreviews = [self excludedSnapshotPreviews];
  if (excludedPreviews) {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:excludedPreviews options:nil error:nil];
    launchEnvironment[@"EXCLUDED_SNAPSHOT_PREVIEWS"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
    
  app.launchEnvironment = launchEnvironment;
  [app launch];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for network response"];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:38824/file"]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (data) {
        NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        resultPath = stringData;
      }

      [expectation fulfill];
  }];

  [task resume];
  [self waitForExpectationsWithTimeout:25 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Test timed out with error: %@", error);
      NSException* myException = [NSException
              exceptionWithName:@"SnapshotError"
              reason:@"Did not receive metadata file"
              userInfo:nil];
      @throw myException;
    }
  }];

  NSLog(@"Images can be found in %@", resultPath);

  NSString *metadataPath = [resultPath stringByAppendingString:@"/metadata.json"];
  NSData *data = [NSData dataWithContentsOfFile:metadataPath];
  NSError *error = nil;
  NSArray *metadata = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
  if (error) {
    XCTFail(@"Error while fetching directory files: %@", [error localizedDescription]);
  } else {
    typeNames = [NSMutableArray array];
    previewIds = [NSMutableArray array];
    self.dynamicTestSelectors = [NSMutableArray array];
    NSMutableArray<NSString *> *previewTypes = [NSMutableArray array];
    int i = 0;
    for (NSDictionary *previewDetails in metadata) {
      NSString *typeName = previewDetails[@"typeName"];
      NSString *displayName = previewDetails[@"displayName"];
      displayName = displayName ? displayName : typeName;
      NSNumber *count = previewDetails[@"numPreviews"];
      for (int j = 0; j < count.intValue; j++) {
        [typeNames addObject:typeName];
        NSString *testSelectorName = [NSString stringWithFormat:@"%@-%d-%d", displayName, j, i];
        [self.dynamicTestSelectors addObject:testSelectorName];
        [previewIds addObject:@(j)];

        BOOL success = class_addMethod([self class], NSSelectorFromString(testSelectorName), (IMP) dynamicTestMethod, "v@:");
        if (!success) {
          NSLog(@"Error adding method %@", testSelectorName);
        }
        i++;
      }
      [previewTypes addObject:typeName];
    }
  }
}

void dynamicTestMethod(id self, SEL _cmd) {
  NSString *selectorName = NSStringFromSelector(_cmd);
  NSString *testNumber = [selectorName componentsSeparatedByString:@"-"].lastObject;
  int index = testNumber.intValue;

  NSString *typeName = typeNames[index];
  NSNumber *previewId = previewIds[index];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for network response"];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:38824/display/%@/%d", typeName, previewId.intValue]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];

  __block NSData *resultData;
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      resultData = data;
      [expectation fulfill];
  }];

  [task resume];

  [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
    if (error) {
      NSLog(@"Test timed out with error: %@", error);
    }
  }];

  if (resultData) {
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:resultData options:nil error:nil];
    if (jsonResult[@"error"]) {
      NSException* myException = [NSException
              exceptionWithName:@"SnapshotError"
              reason:jsonResult[@"error"]
              userInfo:nil];
      @throw myException;
    } else {
      NSString *imagePath = jsonResult[@"imagePath"];
      NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
      if (imageData) {
        NSString *displayName = @"Rendered Preview";
        if (jsonResult[@"displayName"]) {
          displayName = jsonResult[@"displayName"];
        }
        XCTAttachment *attachment = [XCTAttachment attachmentWithUniformTypeIdentifier:@"public.png" name:displayName payload:imageData userInfo:nil];
          attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
          [self addAttachment:attachment];
      }
    }
  }

  if (@available(iOS 17.0, *)) {
    if ([self enableAccessibilityAudit]) {
      XCUIApplication *app = [self getApp];
      [app performAccessibilityAuditWithAuditTypes:[self auditType] issueHandler:^BOOL(XCUIAccessibilityAuditIssue * _Nonnull issue) {
        return [self handleIssue:issue];
      } error:nil];
    }
  }
}

@end
