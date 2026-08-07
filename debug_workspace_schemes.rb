#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

puts "🔍 Debugging workspace scheme configuration..."

# Check if workspace exists (it won't in local development without pod install)
workspace_path = 'myfortune.xcworkspace'
if File.directory?(workspace_path)
  puts "\n✅ Workspace exists: #{workspace_path}"
else
  puts "\n⚠️  Workspace not found (expected - needs pod install)"
  puts "    This is only visible in CI after pod install"
end

# Check project schemes
project_path = 'myfortune.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "\n📋 Project Schemes:"
# Schemes are loaded from xcshareddata/xcschemes directory

# List all available schemes on disk
puts "\n📂 Scheme Files on Disk:"
shared_schemes = Dir.glob("#{project_path}/xcshareddata/xcschemes/*.xcscheme")
shared_schemes.each do |path|
  puts "  ✅ #{path}"
end

if shared_schemes.empty?
  puts "  ❌ No shared schemes found!"
end

# Check target information
puts "\n🎯 Project Targets:"
project.targets.each do |target|
  puts "  - #{target.name}"
  puts "    UUID: #{target.uuid}"
  puts "    Product type: #{target.product_type}"

  # Check build settings that affect platform discovery
  target.build_configurations.each do |config|
    supported = config.build_settings['SUPPORTED_PLATFORMS']
    sdk = config.build_settings['SDKROOT']
    deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
    puts "    #{config.name}:"
    puts "      SUPPORTED_PLATFORMS=#{supported.inspect}"
    puts "      SDKROOT=#{sdk.inspect}"
    puts "      IPHONEOS_DEPLOYMENT_TARGET=#{deployment_target.inspect}"
  end
end

puts "\n✅ Debug complete!"
