#!/usr/bin/swift
import Foundation

// Simple Xcode project generator script
// Usage: swift create-project.swift

let projectName = "myfortune"
let projectPath = FileManager.default.currentDirectoryPath
let appPath = "\(projectPath)/myfortune"

print("📁 Creating Xcode project structure for \(projectName)...")

// Create directory structure
let directories = [
    "\(appPath)",
    "\(appPath)/App",
    "\(appPath)/Views",
    "\(appPath)/Models",
    "\(appPath)/ViewModels",
    "\(appPath)/Services",
    "\(appPath)/Resources",
    "\(appPath)/Resources/Assets.xcassets",
    "\(appPath)/Resources/Assets.xcassets/AppIcon.appiconset",
    "\(appPath)/Resources/Localizable.strings",
    "\(appPath)/SupportingFiles",
    "\(projectPath)/myfortuneTests",
]

for directory in directories {
    try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
}

print("✅ Project structure created!")
print("")
print("📝 Next steps:")
print("1. Open Xcode and create a new iOS project")
print("2. Choose 'App' as the template")
print("3. Product name: myfortune")
print("4. Save in: \(projectPath)")
print("5. Or use: xcode-select -p")
print("")
print("Manual alternative: Use 'xcodebuild -help' to create via CLI")
