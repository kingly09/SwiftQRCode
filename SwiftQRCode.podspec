#
# Be sure to run `pod lib lint SwiftQRCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftQRCode'
  s.version          = '0.1.1'
  s.summary          = 'A short description of SwiftQRCode.'

  s.homepage         = 'https://github.com/kingly09/SwiftQRCode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kingly09' => 'libintm@163.com' }
  s.source           = { :git => 'https://github.com/kingly09/SwiftQRCode.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'SwiftQRCode/Classes/**/*'
  
end
