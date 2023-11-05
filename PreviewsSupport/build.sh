xcodebuild archive \
 -scheme PreviewsSupport \
 -archivePath ./PreviewsSupport-iphonesimulator.xcarchive \
 -sdk iphonesimulator \
 -destination 'generic/platform=iOS Simulator' \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 INSTALL_PATH='Library/Frameworks' \
 SKIP_INSTALL=NO \
 CLANG_CXX_LANGUAGE_STANDARD=c++17

xcodebuild archive \
 -scheme PreviewsSupport \
 -archivePath ./PreviewsSupport-iphoneos.xcarchive \
 -sdk iphoneos \
 -destination 'generic/platform=iOS' \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 INSTALL_PATH='Library/Frameworks' \
 SKIP_INSTALL=NO \
 CLANG_CXX_LANGUAGE_STANDARD=c++17

 xcodebuild archive \
 -scheme PreviewsSupport \
 -archivePath ./PreviewsSupport-macosx.xcarchive \
 -sdk macosx \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 INSTALL_PATH='Library/Frameworks' \
 SKIP_INSTALL=NO \
 CLANG_CXX_LANGUAGE_STANDARD=c++17

xcodebuild -create-xcframework \
 -framework ./PreviewsSupport-iphonesimulator.xcarchive/Products/Library/Frameworks/PreviewsSupport.framework \
 -framework ./PreviewsSupport-iphoneos.xcarchive/Products/Library/Frameworks/PreviewsSupport.framework \
 -framework ./PreviewsSupport-macosx.xcarchive/Products/Library/Frameworks/PreviewsSupport.framework \
 -output ./PreviewsSupport.xcframework
