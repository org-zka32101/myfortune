#!/bin/bash

# myfortune iOS Test Script

set -e

echo "🧪 Running myfortune tests..."

cd myfortune

# Ensure pods are installed
if [ ! -d "Pods" ]; then
    echo "📦 Installing dependencies..."
    pod install
fi

# Run tests
xcodebuild test \
    -workspace myfortune.xcworkspace \
    -scheme myfortune \
    -configuration Debug \
    -sdk iphonesimulator \
    -derivedDataPath Build/Debug

echo "✅ Tests complete!"
