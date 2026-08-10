# Podfile for myfortune iOS App

platform :ios, '14.0'

target 'myfortune' do
  # Enable module headers for Objective-C pods used by Swift
  use_modular_headers!

  # UI & Foundation
  pod 'Alamofire', '~> 5.7'          # HTTP networking
  pod 'SnapKit', '~> 5.6'            # Auto-layout DSL
  pod 'Then'                          # Syntactic sugar for Swift

  # Storage & Data
  pod 'RealmSwift', '~> 10.0'        # Database

  # Analytics & Logging
  pod 'FirebaseAnalytics'             # Firebase Analytics
  pod 'FirebaseMessaging'             # Push notifications

  # Monetization
  pod 'Google-Mobile-Ads-SDK'         # AdMob interstitial ads for free users

  # Development
  target 'myfortuneTests' do
    inherit! :search_paths
    use_modular_headers!
    pod 'Quick'                       # BDD testing framework
    pod 'Nimble'                      # Matcher framework
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'COCOAPODS=1',
      ]
    end
  end
end
