# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'EBL-Test' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EBL-Test
  pod 'Firebase'
  pod 'Firebase/Core'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'SVProgressHUD'
  pod 'NVActivityIndicatorView'
  pod 'SideMenu'
  pod 'ChameleonFramework'
  pod 'Segmentio', '~> 3.3'
  pod 'Kingfisher', '~> 5.0'
  pod 'Charts'
  pod 'SkeletonView'
  pod 'MKDropdownMenu'
  
end

# ignore all warnings from all pods
inhibit_all_warnings!

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
