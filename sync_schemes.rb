#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

project_path = 'myfortune.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "🔄 Syncing schemes with project UUIDs..."

# Remove old schemes
shared_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
FileUtils.rm_rf(shared_dir) if File.directory?(shared_dir)
FileUtils.mkdir_p(shared_dir)

# Create schemes for each target with correct UUIDs
project.targets.each do |target|
  puts "  Creating scheme for #{target.name} (UUID: #{target.uuid})"

  scheme = Xcodeproj::XCScheme.new(target.name)

  # Add the target to the build action with correct UUID
  scheme.add_build_target(target, buildable_name: "#{target.product_name}.app")

  # Save to shared location
  scheme.save_as(project_path, target.name, shared: true)
end

puts "✅ Schemes synced with project UUIDs"

# Verify the schemes
puts "\n🔍 Verifying schemes..."
Dir.glob("#{shared_dir}/*.xcscheme").each do |scheme_file|
  puts "  ✅ #{File.basename(scheme_file)}"
end
