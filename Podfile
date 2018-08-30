platform :ios, '9.0'

target 'BlockoneLab' do
  use_frameworks!

	pod 'MagicalRecord'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
    end
  end
end

