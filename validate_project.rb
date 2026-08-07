#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'myfortune.xcodeproj'

puts "🔍 Validating Xcode project structure..."
puts "=" * 60

begin
  # Load the project
  project = Xcodeproj::Project.open(project_path)

  puts "✅ Project loaded successfully"
  puts "   Path: #{project.path}"

  # Check root object
  root = project.root_object
  unless root
    puts "❌ ERROR: No root object found!"
    exit 1
  end
  puts "✅ Root object exists"

  # Check targets
  puts "\n📋 Targets:"
  project.targets.each do |target|
    puts "   ✅ #{target.name}"
    puts "      Type: #{target.product_type}"
    puts "      Build configs: #{target.build_configurations.count}"

    # Validate build configuration list
    unless target.build_configuration_list
      puts "      ❌ ERROR: Missing build_configuration_list!"
      exit 1
    end

    # Check that all build configs exist
    target.build_configurations.each do |config|
      puts "         - #{config.name}: #{config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']}"
    end
  end

  # Check build phases
  puts "\n⚙️  Build Phases:"
  project.targets.each do |target|
    puts "   #{target.name}:"
    target.build_phases.each do |phase|
      puts "      - #{phase.class.name.split('::').last}: #{phase.files.count} files" rescue puts "      - #{phase.class.name.split('::').last}"
    end
  end

  # Check file references
  puts "\n📁 Source Files:"
  source_count = 0
  project.files.each do |file|
    next unless file.real_path.to_s.include?('.swift')
    puts "   ✅ #{file.real_path.basename}"
    source_count += 1
  end
  puts "   Total: #{source_count} Swift files"

  # Check resources
  puts "\n📦 Resources:"
  resource_count = 0
  project.files.each do |file|
    path = file.real_path.to_s
    if path.include?('Assets.xcassets') || path.include?('.storyboard') || path.include?('Info.plist')
      puts "   ✅ #{file.real_path.basename}"
      resource_count += 1
    end
  end
  puts "   Total: #{resource_count} resource files"

  # Validate project configuration list
  puts "\n🔧 Project Configurations:"
  if project.build_configuration_list
    puts "   ✅ build_configuration_list exists"
    project.build_configurations.each do |config|
      puts "      - #{config.name}"
    end
  else
    puts "   ❌ ERROR: No build_configuration_list for project!"
    exit 1
  end

  puts "\n" + "=" * 60
  puts "✅ Project validation passed!"
  puts "=" * 60

rescue Xcodeproj::Informative => e
  puts "❌ ERROR: #{e.message}"
  exit 1
rescue => e
  puts "❌ ERROR: #{e.class.name} - #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end
