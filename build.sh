#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

PROJECT_BUILD_DIR="${PROJECT_BUILD_DIR:-"${PROJECT_ROOT}/build"}"
XCODEBUILD_BUILD_DIR="$PROJECT_BUILD_DIR/xcodebuild"
XCODEBUILD_DERIVED_DATA_PATH="$XCODEBUILD_BUILD_DIR/DerivedData"

build_framework() {
    local sdk="$1"
    local destination="$2"
    local scheme="$3"

    local XCODEBUILD_ARCHIVE_PATH="./$scheme-$sdk.xcarchive"

    rm -rf "$XCODEBUILD_ARCHIVE_PATH"

    xcodebuild archive \
        -scheme $scheme \
        -archivePath $XCODEBUILD_ARCHIVE_PATH \
        -derivedDataPath "$XCODEBUILD_DERIVED_DATA_PATH" \
        -sdk "$sdk" \
        -destination "$destination" \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        INSTALL_PATH='Library/Frameworks' \
        OTHER_SWIFT_FLAGS=-no-verify-emitted-module-interface

    FRAMEWORK_MODULES_PATH="$XCODEBUILD_ARCHIVE_PATH/Products/Library/Frameworks/$scheme.framework/Modules"
    mkdir -p "$FRAMEWORK_MODULES_PATH"
    cp -r \
    "$XCODEBUILD_DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/BuildProductsPath/Release-$sdk/$scheme.swiftmodule" \
    "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"
    # Delete private swiftinterface
    rm -f "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule/*.private.swiftinterface"
    find "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule" -type f -name "*.swiftinterface" | while read -r file; do
      # Remove lines containing "NSInvocation"
      sed -e '/NSInvocation/d' -e 's/XCTest\.//g' "$file" > temp && mv temp "$file"
    done

}

# Update the Package.swift to build the library as dynamic instead of static
sed -i '' '/Replace this/ s/.*/type: .dynamic,/' Package.swift

# Build SnapshottingTests
build_framework "iphonesimulator" "generic/platform=iOS Simulator" "SnapshottingTests"
build_framework "iphoneos" "generic/platform=iOS" "SnapshottingTests"

# Build PreviewGallery
build_framework "iphonesimulator" "generic/platform=iOS Simulator" "PreviewGallery"
build_framework "iphoneos" "generic/platform=iOS" "PreviewGallery"

echo "Builds completed successfully."

rm -rf "SnapshottingTests.xcframework"
xcodebuild -create-xcframework -framework SnapshottingTests-iphonesimulator.xcarchive/Products/Library/Frameworks/SnapshottingTests.framework -framework SnapshottingTests-iphoneos.xcarchive/Products/Library/Frameworks/SnapshottingTests.framework -output SnapshottingTests.xcframework

rm -rf "PreviewGallery.xcframework"
xcodebuild -create-xcframework -framework PreviewGallery-iphonesimulator.xcarchive/Products/Library/Frameworks/PreviewGallery.framework -framework PreviewGallery-iphoneos.xcarchive/Products/Library/Frameworks/PreviewGallery.framework -output PreviewGallery.xcframework