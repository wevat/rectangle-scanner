#
# Be sure to run `pod lib lint RectangleScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RectangleScanner'
  s.version          = '0.1.0'
  s.summary          = 'A UIViewController with callbacks for scanning rectangles.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Use this library to scan rectangles.
Simply point, tap & hold, and voila.
Our favourite is receipts, however we don't judge you based on your rectangle preference.
                       DESC

  s.homepage         = 'https://github.com/wevat/rectangle-scanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Harry Bloom' => 'harry@wevat.com' }
  s.source           = { :git => 'https://github.com/wevat/rectangle-scanner.git', :tag => '0.1.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.0'

  s.source_files = 'RectangleScanner/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RectangleScanner' => ['RectangleScanner/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
