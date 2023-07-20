# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Weather' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Pods for Weather
	pod 'Alamofire', '4.9.1'
  pod 'RxSwift', '6.2.0'
  pod 'RxCocoa', '6.2.0'
  pod 'RealmSwift', '10.37.0'
  pod 'RxDataSources', '5.0.0'

  target 'WeatherTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Nimble', '10.0.0'
    pod 'Quick', '5.0.1'
    pod 'RxTest', '6.2.0'
    pod 'RxBlocking', '6.2.0'
  end

  target 'WeatherUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                 end
            end
     end
  end
end
