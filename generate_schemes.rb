#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

project_path = 'myfortune.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "🔄 Generating scheme files with correct UUIDs..."

# Get the correct UUIDs from the project
app_target = project.targets.find { |t| t.name == 'myfortune' }
test_target = project.targets.find { |t| t.name == 'myfortuneTests' }

raise "Could not find app target" unless app_target
raise "Could not find test target" unless test_target

puts "  App target UUID: #{app_target.uuid}"
puts "  Test target UUID: #{test_target.uuid}"

# Create shared schemes directory
shared_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
FileUtils.rm_rf(shared_dir)
FileUtils.mkdir_p(shared_dir)

# Generate app scheme
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

# Write app scheme
File.write(File.join(shared_dir, 'myfortune.xcscheme'), app_scheme_xml)
puts "  ✅ Created myfortune.xcscheme with correct UUID"

# Generate test scheme
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

# Write test scheme
File.write(File.join(shared_dir, 'myfortuneTests.xcscheme'), test_scheme_xml)
puts "  ✅ Created myfortuneTests.xcscheme with correct UUID"

puts "\n✅ Schemes generated with correct UUIDs!"
