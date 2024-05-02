interfaces = Dir['../PreviewsSupport.xcframework/**/*.swiftinterface']


for file_path in interfaces
  contents = File.read(file_path)
  to_remove = """@available(iOS 17.0, macOS 14.0, *)
extension UIKit.UIViewPreviewSource : PreviewsSupport.MakeUIViewProvider {
}
@available(iOS 17.0, macOS 14.0, *)
extension UIKit.UIViewControllerPreviewSource : PreviewsSupport.MakeViewControllerProvider {
}
@available(iOS 17.0, macOS 14.0, *)
extension SwiftUI.ViewPreviewSource : PreviewsSupport.MakeViewProvider {
}"""
  swift_ui_only_remove = """@available(iOS 17.0, macOS 14.0, *)
extension SwiftUI.ViewPreviewSource : PreviewsSupport.MakeViewProvider {
}"""
  if contents.include?(to_remove)
    contents.slice!(to_remove)
    File.write(file_path, contents)
  elsif contents.include?(swift_ui_only_remove)
    contents.slice!(swift_ui_only_remove)
    File.write(file_path, contents)
  end
end
