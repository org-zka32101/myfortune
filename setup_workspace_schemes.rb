#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

puts "🔧 Setting up workspace schemes for CI..."

# Paths
project_path = 'myfortune.xcodeproj'
workspace_path = 'myfortune.xcworkspace'

# Load project
project = Xcodeproj::Project.open(project_path)

# Check if workspace exists
if !File.directory?(workspace_path)
  puts "❌ Workspace not found at #{workspace_path}"
  puts "   Run 'pod install' first"
  exit 1
end

puts "✅ Workspace found"

# Create workspace-level schemes directory
workspace_schemes_dir = File.join(workspace_path, 'xcshareddata', 'xcschemes')
FileUtils.mkdir_p(workspace_schemes_dir)
puts "✅ Workspace schemes directory ready: #{workspace_schemes_dir}"

# Get project target UUIDs
app_target = project.targets.find { |t| t.name == 'myfortune' }
test_target = project.targets.find { |t| t.name == 'myfortuneTests' }

unless app_target && test_target
  puts "❌ Could not find required targets"
  exit 1
end

puts "✅ Found targets:"
puts "   - myfortune (#{app_target.uuid})"
puts "   - myfortuneTests (#{test_target.uuid})"

# Ensure project-level schemes are up to date
project_schemes_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
FileUtils.mkdir_p(project_schemes_dir)

# Display target info for debugging
puts "\nTarget platform configuration:"
app_target.build_configurations.each do |config|
  puts "  #{app_target.name} (#{config.name}):"
  puts "    SUPPORTED_PLATFORMS: #{config.build_settings['SUPPORTED_PLATFORMS']}"
  puts "    SDKROOT: #{config.build_settings['SDKROOT']}"
  puts "    IPHONEOS_DEPLOYMENT_TARGET: #{config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']}"
end

# Create/update app scheme
app_scheme_xml = <<-SCHEME
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "#{app_target.uuid}"
               BuildableName = "myfortune.app"
               BlueprintName = "myfortune"
               ReferencedContainer = "container:myfortune.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{app_target.uuid}"
            BuildableName = "myfortune.app"
            BlueprintName = "myfortune"
            ReferencedContainer = "container:myfortune.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "#{test_target.uuid}"
               BuildableName = "myfortuneTests.xctest"
               BlueprintName = "myfortuneTests"
               ReferencedContainer = "container:myfortune.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{app_target.uuid}"
            BuildableName = "myfortune.app"
            BlueprintName = "myfortune"
            ReferencedContainer = "container:myfortune.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{app_target.uuid}"
            BuildableName = "myfortune.app"
            BlueprintName = "myfortune"
            ReferencedContainer = "container:myfortune.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME

File.write(File.join(project_schemes_dir, 'myfortune.xcscheme'), app_scheme_xml)
puts "✅ Updated myfortune.xcscheme"

# Create/update test scheme
test_scheme_xml = <<-SCHEME
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "#{test_target.uuid}"
               BuildableName = "myfortuneTests.xctest"
               BlueprintName = "myfortuneTests"
               ReferencedContainer = "container:myfortune.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{test_target.uuid}"
            BuildableName = "myfortuneTests.xctest"
            BlueprintName = "myfortuneTests"
            ReferencedContainer = "container:myfortune.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{test_target.uuid}"
            BuildableName = "myfortuneTests.xctest"
            BlueprintName = "myfortuneTests"
            ReferencedContainer = "container:myfortune.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{test_target.uuid}"
            BuildableName = "myfortuneTests.xctest"
            BlueprintName = "myfortuneTests"
            ReferencedContainer = "container:myfortune.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME

File.write(File.join(project_schemes_dir, 'myfortuneTests.xcscheme'), test_scheme_xml)
puts "✅ Updated myfortuneTests.xcscheme"

# Verify the schemes
puts "\n🔍 Verifying scheme files:"
Dir.glob("#{project_schemes_dir}/*.xcscheme").each do |scheme_file|
  size = File.size(scheme_file)
  puts "  ✅ #{File.basename(scheme_file)} (#{size} bytes)"
end

puts "\n✅ Workspace schemes setup complete!"
