swiftui_interface = Dir['/Applications/Xcode.app/Contents/Developer/Platforms/**/SwiftUI.framework/**/*.swiftinterface']
uikit_interface = Dir['/Applications/Xcode.app/Contents/Developer/Platforms/**/UIKit.framework/**/*.swiftinterface']

for file_path in swiftui_interface
  if !File.read(file_path).include?("ViewPreviewSource")
    File.open(file_path, 'a') do |file|
      file.puts("@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
      public struct ViewPreviewSource {
        public var makeView: @_Concurrency.MainActor () -> any SwiftUI.View
      }")
    end
  end
end

for file_path in uikit_interface
  if !file_path.include?("Watch") && !File.read(file_path).include?("UIViewPreviewSource")
    File.open(file_path, 'a') do |file|
      file.puts("@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
      public struct UIViewPreviewSource {
        public var makeView: @_Concurrency.MainActor () -> UIKit.UIView
      }
      
      @available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
      public struct UIViewControllerPreviewSource {
        public var makeViewController: @_Concurrency.MainActor () -> UIKit.UIViewController
      }")
    end
  end
end