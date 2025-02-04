//
//  EMGInvocationCreator.m
//
//
//  Created by Noah Martin on 8/9/24.
//

#import <Foundation/Foundation.h>

@interface EMGInvocationCreator: NSObject

+ (NSInvocation *)create:(NSString *)selectorName;

@end

@implementation EMGInvocationCreator

+ (NSInvocation *)create:(NSString *)selectorName {
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
  invocation.selector = NSSelectorFromString(selectorName);
  return  invocation;
}

#if TARGET_OS_TV || TARGET_OS_WATCH || TARGET_OS_VISION || !(defined(__arm64__) || defined(__aarch64__))
  #define EMG_ENABLE_FIX_TIME 0
#else
  #define EMG_ENABLE_FIX_TIME 1
#endif

#if EMG_ENABLE_FIX_TIME

#import <sys/time.h>
#import <mach/thread_status.h>
#import <mach/vm_types.h>
#import <SimpleDebugger.h>

SimpleDebugger *handler;

int gettimeofday_new(struct timeval *t, void *a) {
  t->tv_sec = 1723532400;
  t->tv_usec = 0;
  return 0;
}

#endif

+ (void)hookTime {
#if EMG_ENABLE_FIX_TIME
  handler = new SimpleDebugger();
  handler->hookFunction((void *) &gettimeofday, (void *) &gettimeofday_new);
#endif
}

+ (void)load {
  NSDictionary<NSString *, NSString *> *env = [[NSProcessInfo processInfo] environment];
  if (![[env objectForKey:@"EMERGE_DISABLE_FIX_TIME"] isEqualToString:@"1"]) {
    [self hookTime];
  }
  id previewBaseTest = NSClassFromString(@"EMGPreviewBaseTest");
  [previewBaseTest performSelector:@selector(swizzle:) withObject:[self class]];
}

@end
