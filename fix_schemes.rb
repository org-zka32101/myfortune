#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

project_path = 'myfortune.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "🔧 Fixing scheme locations..."

# Get the schemes from the project
schemes_dir = File.join(project_path, 'xcuserdata', '.xcuserdatad', 'xcschemes')

if File.directory?(schemes_dir)
  # Create shared schemes directory
  shared_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
  FileUtils.mkdir_p(shared_dir)

  # Copy schemes to shared location
  Dir.glob("#{schemes_dir}/*.xcscheme").each do |scheme_file|
    scheme_name = File.basename(scheme_file)
    shared_path = File.join(shared_dir, scheme_name)
    puts "  Copying #{scheme_name} to shared location..."
    FileUtils.cp(scheme_file, shared_path)
  end

  puts "✅ Schemes moved to shared location (xcshareddata)"
else
  puts "⚠️  No user schemes found, creating shared schemes directly..."

  # Create shared schemes directory
  shared_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
  FileUtils.mkdir_p(shared_dir)

  # Create schemes for each target
  project.targets.each do |target|
    puts "  Creating scheme for #{target.name}..."
    scheme = Xcodeproj::XCScheme.new(target.name)
    scheme.add_build_target(target)
    scheme.save_as(project_path, target.name, shared: true)
  end

  puts "✅ Schemes created in shared location"
end

puts "✅ Done!"
