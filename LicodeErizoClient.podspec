Pod::Spec.new do |spec|
  spec.license                = 'MIT'
  spec.platform               = 'ios', '12.0'
  spec.version                = '2.0.0'
  spec.name                   = 'LicodeErizoClient'
  spec.summary                = 'iOS Client for Licode WebRTC framework'
  spec.authors                = { 'Alvaro Gil' => 'zeliang.shao@gmail.com' }
  spec.homepage               = 'https://www.google.com'
  spec.source                 = { :git => 'git@github.com:Tomas-Shao/Licode-ErizoClientIOS.git', :tag => "#{spec.version}" }
  spec.source_files           = [ 'ErizoClient/**/*.{h,m}', 'Vendor/**/*.{h,m}', 'ErizoClient/**/*.swift']
  spec.dependency 'GoogleWebRTC'
  spec.dependency 'Socket.IO-Client-Swift', '15.0.0'
  spec.libraries = 'icucore'
  spec.pod_target_xcconfig   = {
    'ENABLE_BITCODE' => 'NO',
    'SWIFT_VERSION' => '5.0'
  }
end
