source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

platform :ios, :deployment_target => '11.0'

workspace './ErizoClientIOS.xcworkspace'

target 'ErizoClient' do
  platform :ios, :deployment_target => '11.0'
  project 'ErizoClientIOS'
  pod 'GoogleWebRTC'
  pod 'Socket.IO-Client-Swift', '~> 15.0.0'
end

target 'ErizoClientTests' do
  platform :ios, :deployment_target => '11.0'
  inherit! :search_paths
  pod 'GoogleWebRTC'
  pod 'Socket.IO-Client-Swift', '~> 15.0.0'
  pod 'OCMockito', '~> 4.0'
end

target 'ECIExampleLicode' do
  platform :ios, :deployment_target => '11.0'
  project 'ECIExampleLicode/ECIExampleLicode'
  pod 'GoogleWebRTC'
  pod 'Socket.IO-Client-Swift', '~> 15.0.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end
    end
  end

end
