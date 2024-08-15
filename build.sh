#!/bin/bash

set -e

build_framework() {
    local sdk="$1"
    local destination="$2"

    xcodebuild archive \
        -scheme SnapshottingTests \
        -target SnapshottingTests \
        -archivePath "./SnapshottingTests-$sdk.xcarchive" \
        -sdk "$sdk" \
        -destination "$destination" \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        INSTALL_PATH='Library/Frameworks' \
        SKIP_INSTALL=NO \
        OTHER_SWIFT_FLAGS='-no-verify-emitted-module-interface'
    
    pushd "./SnapshottingTests-$sdk.xcarchive/Products/Library/Frameworks/"
    
    if [ "$sdk" = "iphonesimulator" ]; then
    lipo AccessibilitySnapshotCore-ObjC.o -thin arm64 -output AccessibilitySnapshotCore-arm64.o
    rm AccessibilitySnapshotCore-ObjC.o
    fi
    ar -crs libSnapshottingTests.a *.o
    
    popd
}

build_framework "iphonesimulator" "generic/platform=iOS Simulator"
build_framework "iphoneos" "generic/platform=iOS"

echo "Builds completed successfully."

xcodebuild -create-xcframework -library SnapshottingTests-iphonesimulator.xcarchive/Products/Library/Frameworks/libSnapshottingTests.a -library SnapshottingTests-iphoneos.xcarchive/Products/Library/Frameworks/libSnapshottingTests.a -output SnapshottingTests.xcframework