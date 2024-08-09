//
//  EMGPreviewBaseTest.h
//  DemoApp
//
//  Created by Noah Martin on 7/14/23.
//

#ifndef EMGPreviewBaseTest_h
#define EMGPreviewBaseTest_h

#import <XCTest/XCTest.h>

@interface EMGDiscoveredPreview : NSObject

@property (retain, nonatomic, nonnull) NSString *typeName;
@property (retain, nonatomic, nullable) NSString *displayName;
@property (retain, nonatomic, nonnull) NSNumber *numberOfPreviews;

@end

@interface EMGPreview: NSObject

@property (retain, nonatomic, nonnull) EMGDiscoveredPreview *preview;
@property (retain, nonatomic, nonnull) NSNumber *index;

@end

@interface EMGPreviewBaseTest: XCTestCase

+ (nonnull instancetype)create;

+ (nonnull NSArray<EMGDiscoveredPreview *> *)discoverPreviews;

- (void)testPreview:(EMGPreview *_Nonnull)preview;

@end

#endif /* EMGPreviewBaseTest_h */
