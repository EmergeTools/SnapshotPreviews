//
//  DynamicTest.h
//  DemoApp
//
//  Created by Noah Martin on 7/14/23.
//

#ifndef DynamicTest_h
#define DynamicTest_h

#import <XCTest/XCTest.h>

@interface PreviewTest: XCTestCase

- (nonnull XCUIApplication *)getApp;

// Override to return a list of previews that should be snapshotted.
// The default is null, which snapshots all previews.
// Elements should be the type name of the preview, like "MyModule.MyView_Previews"
- (nullable NSArray<NSString *> *)snapshotPreviews;

@end


#endif /* DynamicTest_h */