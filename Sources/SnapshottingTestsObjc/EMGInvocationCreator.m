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

+ (void)load {
  id previewBaseTest = NSClassFromString(@"EMGPreviewBaseTest");
  [previewBaseTest performSelector:@selector(swizzle:) withObject:[self class]];
}

@end
