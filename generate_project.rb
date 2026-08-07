#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

# Remove existing project if it exists
project_path = 'myfortune.xcodeproj'
FileUtils.rm_rf(project_path) if File.exist?(project_path)

# Create project from scratch
project = Xcodeproj::Project.new(project_path)
project.initialize_from_scratch

# Create group structure
app_group = project.main_group.new_group('myfortune')
views_group = app_group.new_group('Views')
models_group = app_group.new_group('Models')
services_group = app_group.new_group('Services')
test_group = project.main_group.new_group('myfortuneTests')

# Create main target (myfortune app)
puts "Creating myfortune app target..."
app_target = project.new_target(:application, 'myfortune', :ios, '14.0')

# Create test target
puts "Creating myfortuneTests target..."
test_target = project.new_target(:unit_test_bundle, 'myfortuneTests', :ios, '14.0')
test_target.add_dependency(app_target)

# Add source files to app target
puts "Adding source files..."
source_files = {
  app_group => ['myfortune/AppDelegate.swift', 'myfortune/SceneDelegate.swift'],
  views_group => ['myfortune/Views/HomeViewController.swift'],
  models_group => ['myfortune/Models/Fortune.swift'],
  services_group => ['myfortune/Services/FortuneService.swift'],
}

source_files.each do |group, files|
  files.each do |file_path|
    if File.exist?(file_path)
      file_ref = group.new_file(file_path)
      app_target.add_file_references([file_ref])
      puts "  Added: #{file_path}"
    else
      puts "  ⚠️  Missing: #{file_path}"
    end
  end
end

# Add resource files to app target
puts "Adding resource files..."
resource_files = [
  'myfortune/LaunchScreen.storyboard',
  'myfortune/Assets.xcassets',
  'myfortune/Info.plist',
]

resource_files.each do |file_path|
  if File.exist?(file_path)
    file_ref = app_group.new_file(file_path)
    app_target.add_resources([file_ref])
    puts "  Added: #{file_path}"
  else
    puts "  ⚠️  Missing: #{file_path}"
  end
end

# Add test files to test target
puts "Adding test files..."
test_files = ['myfortuneTests/FortuneServiceTests.swift']
test_files.each do |file_path|
  if File.exist?(file_path)
    file_ref = test_group.new_file(file_path)
    test_target.add_file_references([file_ref])
    puts "  Added: #{file_path}"
  else
    puts "  ⚠️  Missing: #{file_path}"
  end
end

# Configure build settings for app target
puts "Configuring app target build settings..."
app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.myfortune'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['INFOPLIST_FILE'] = 'myfortune/Info.plist'
  config.build_settings['INFOPLIST_KEY_UIApplicationDelegate'] = 'myfortune.AppDelegate'
  config.build_settings['INFOPLIST_KEY_UIApplicationSceneManifestLaunchScreen'] = 'LaunchScreen.storyboard'
  config.build_settings['SWIFT_VERSION'] = '5.9'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
  config.build_settings['ALWAYS_SEARCH_USER_PATHS'] = 'NO'
  config.build_settings['SDKROOT'] = 'iphoneos'
end

# Configure build settings for test target
puts "Configuring test target build settings..."
test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.myfortuneTests'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['SWIFT_VERSION'] = '5.9'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/myfortune.app/myfortune'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks']
  config.build_settings['ALWAYS_SEARCH_USER_PATHS'] = 'NO'
  config.build_settings['SDKROOT'] = 'iphoneos'
end

# Create and configure schemes
puts "Creating and configuring schemes..."
project.recreate_user_schemes

# Save the project
puts "Saving project..."
project.save

puts "\n✅ Project generated successfully at #{project_path}"
puts "✅ App target: myfortune"
puts "✅ Test target: myfortuneTests"
puts "✅ Schemes configured"
