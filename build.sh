#!/bin/bash

# Build script for GentleCompanion app with CloudKit support

echo "Building GentleCompanion app with CloudKit support..."

# Clean previous build
rm -rf build/ .build/

# Create build directory
mkdir -p build/

# Build the app using swift build
echo "Running swift build..."
set -x
swift build -c debug --arch x86_64 2>&1 | tail -n 50
set +x

# Check if swift build succeeded
if [ -f ".build/x86_64-apple-macosx/debug/GentleCompanion" ]; then
    echo "Swift build completed successfully!"
    
    # Create app bundle structure
    mkdir -p build/GentleCompanion.app/Contents/MacOS
    mkdir -p build/GentleCompanion.app/Contents/Resources
    
    # Copy binary
    cp .build/x86_64-apple-macosx/debug/GentleCompanion build/GentleCompanion.app/Contents/MacOS/
    
    # Copy Info.plist
    cp Info.plist build/GentleCompanion.app/Contents/
    
    # Copy entitlements
    cp GentleCompanion.entitlements build/GentleCompanion.app/Contents/
    
    # Copy resources
    cp -r Assets.xcassets build/GentleCompanion.app/Contents/Resources/
    cp -r Resources/* build/GentleCompanion.app/Contents/Resources/ 2>/dev/null || true
    
    # Sign the app with entitlements
    echo "Signing app with entitlements..."
    codesign --force --sign - --entitlements GentleCompanion.entitlements build/GentleCompanion.app 2>&1
    
    echo "Build completed successfully!"
    echo "App location: build/GentleCompanion.app"
else
    echo "Build failed with errors."
    exit 1
fi