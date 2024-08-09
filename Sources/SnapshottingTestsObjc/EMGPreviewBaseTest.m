//
//  EMGPreviewBaseTest.m
//  
//
//  Created by Noah Martin on 8/9/24.
//

#import <Foundation/Foundation.h>
#import "EMGPreviewBaseTest.h"
#import <objc/runtime.h>

@implementation EMGDiscoveredPreview

@end

@implementation EMGPreview

@end

static NSMutableArray<EMGPreview *> *previews;

@implementation EMGPreviewBaseTest

+ (instancetype)create {
  return [[self alloc] init];
}

+ (NSArray<NSInvocation *> *)testInvocations {
    NSArray<NSString *> *dynamicTestSelectors = [self addMethods];
    EMGPreviewBaseTest *testInstance = [self create];
    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];
    for (NSString *testName in dynamicTestSelectors) {
        SEL selector = NSSelectorFromString(testName);
        NSMethodSignature *signature = [testInstance methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = selector;
        [invocations addObject:invocation];
    }
    return invocations;
}

+ (NSArray<NSString *> *)addMethods {
  NSMutableArray<NSString *> *dynamicTestSelectors = [NSMutableArray new];
  NSArray<EMGDiscoveredPreview *> *discoveredPreviews = [self discoverPreviews];
  previews = [NSMutableArray new];
  int i = 0;
  for (EMGDiscoveredPreview *discoveredPreview in discoveredPreviews) {
    NSString *typeName = discoveredPreview.typeName;
    NSString *displayName = discoveredPreview.displayName;
    displayName = displayName ? displayName : typeName;
    int count = discoveredPreview.numberOfPreviews.intValue;
    for (int j = 0; j < count; j++) {
      NSString *testSelectorName = [NSString stringWithFormat:@"%@-%d-%d", displayName, j, i];
      [dynamicTestSelectors addObject:testSelectorName];
      EMGPreview *preview = [EMGPreview new];
      preview.preview = discoveredPreview;
      preview.index = @(j);
      [previews addObject:preview];

      BOOL success = class_addMethod([self class], NSSelectorFromString(testSelectorName), (IMP) dynamicTestMethod, "v@:");
      if (!success) {
        NSLog(@"Error adding method %@", testSelectorName);
      }
      i++;
    }
  }
  return dynamicTestSelectors;
}

void dynamicTestMethod(id self, SEL _cmd) {
  NSString *selectorName = NSStringFromSelector(_cmd);
  NSString *testNumber = [selectorName componentsSeparatedByString:@"-"].lastObject;
  int index = testNumber.intValue;
  EMGPreview *preview = previews[index];
  [self testPreview:preview];
}

- (void)testPreview:(EMGPreview *)preview {
  NSLog(@"This should be implemented by a subclass");
}

+ (NSArray<EMGDiscoveredPreview *> *)discoverPreviews {
  NSLog(@"This should be implemented by a subclass");
  return @[];
}

@end
