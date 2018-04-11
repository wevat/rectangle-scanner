#
# Be sure to run `pod lib lint RectangleScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RectangleScanner'
  s.version          = '1.0.0-beta2'
  s.summary          = 'A UIViewController with callbacks for scanning rectangles.'

  s.description      = <<-DESC
Use this library to scan rectangles.
Simply point at a rectangle, tap the take picture button, and voila. The rectangle will be processed, cropped and provided back to you for your leisure.
Our favourite is receipts, however we don't judge you based on your rectangle preference.
                       DESC

  s.homepage         = 'https://github.com/wevat/rectangle-scanner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Harry Bloom' => 'harry@wevat.com' }
  s.source           = { :git => 'https://github.com/wevat/rectangle-scanner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'

  s.source_files = 'RectangleScanner/Classes/**/*'
  s.resources = 'RectangleScanner/Assets/*.xcassets'
  s.resource_bundles = {
    'CameraStreamProvider' => ['RectangleScanner/Assets/*.xcassets']
  }
end
