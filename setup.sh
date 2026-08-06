#!/bin/bash

# myfortune iOS Setup Script

set -e

echo "🚀 Setting up myfortune iOS project..."

# Check for Ruby and CocoaPods
if ! command -v pod &> /dev/null; then
    echo "📦 Installing CocoaPods..."
    sudo gem install cocoapods
fi

# Install dependencies
echo "📚 Installing dependencies via CocoaPods..."
cd myfortune
pod install

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open myfortune.xcworkspace in Xcode:"
echo "   open myfortune.xcworkspace"
echo ""
echo "2. Select the target 'myfortune'"
echo "3. Select your development team in Signing & Capabilities"
echo "4. Build and run (Cmd + R)"
