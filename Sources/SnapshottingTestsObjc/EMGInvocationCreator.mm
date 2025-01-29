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

void callback(mach_port_t thread, arm_thread_state64_t state, std::function<void(bool removeBreak)> a) {
  state.__pc = (__uint64_t) &gettimeofday_new;
  thread_set_state(thread, ARM_THREAD_STATE64, (thread_state_t) &state, ARM_THREAD_STATE64_COUNT);
  a(false);
}

#endif

+ (void)hookTime {
#if EMG_ENABLE_FIX_TIME
  vm_address_t a = (vm_address_t) &gettimeofday;
  handler = new SimpleDebugger();
  handler->setBreakpoint(a);
  handler->setExceptionCallback(&callback);
  handler->startDebugging();
#endif
}

+ (void)load {
  NSDictionary<NSString *, NSString *> *env = [[NSProcessInfo processInfo] environment];
  if ([[env objectForKey:@"EMERGE_SHOULD_FIX_TIME"] isEqualToString:@"1"]) {
    [self hookTime];
  }
  id previewBaseTest = NSClassFromString(@"EMGPreviewBaseTest");
  [previewBaseTest performSelector:@selector(swizzle:) withObject:[self class]];
}

@end
