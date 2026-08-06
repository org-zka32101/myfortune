#!/bin/bash

# myfortune iOS Build Script

set -e

CONFIGURATION=${1:-Debug}
PLATFORM=${2:-iphonesimulator}

echo "🔨 Building myfortune ($CONFIGURATION - $PLATFORM)..."

cd myfortune

# Ensure pods are installed
if [ ! -d "Pods" ]; then
    echo "📦 Installing dependencies..."
    pod install
fi

# Build
xcodebuild \
    -workspace myfortune.xcworkspace \
    -scheme myfortune \
    -configuration $CONFIGURATION \
    -sdk $PLATFORM \
    -derivedDataPath Build/$CONFIGURATION

echo "✅ Build complete!"
echo "📦 Output: Build/$CONFIGURATION"
