//
//  Initializer.m
//  
//
//  Created by Noah Martin on 7/12/23.
//

#import <Foundation/Foundation.h>
@import SnapshottingSwift;
@import UIKit;

__attribute__((constructor)) static void setup(void);
__attribute__((constructor)) static void setup(void) {
  char* str = getenv("EMERGE_IS_RUNNING_FOR_SNAPSHOTS");
  if (str && strcmp(str, "1") == 0) {
    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
      [[Initializer shared] start];
    }];
  }
}
