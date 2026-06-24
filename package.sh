#!/bin/bash

# Package script for GentleCompanion app using Swift Package Manager

echo "Packaging GentleCompanion app..."

# Navigate to GentleCompanion directory
cd "$(dirname "$0")/GentleCompanion" || {
    echo "GentleCompanion directory not found!"
    exit 1
}

# Clean previous builds and packages
rm -rf ../GentleCompanion.app
rm -rf ../GentleCompanion.dmg
rm -rf build/

# Create build directory
mkdir -p build/

# Build the app in release mode
echo "Building app in release mode..."
swift build -c release

# Check if build succeeded
if [ ! -f ".build/release/GentleCompanion" ]; then
    echo "Build failed!"
    exit 1
fi

# Create app bundle structure
echo "Creating app bundle structure..."
mkdir -p ../GentleCompanion.app/Contents/MacOS
mkdir -p ../GentleCompanion.app/Contents/Resources
mkdir -p ../GentleCompanion.app/Contents/Resources/Assets.xcassets

# Copy executable
cp .build/release/GentleCompanion ../GentleCompanion.app/Contents/MacOS/

# Copy Info.plist
cp Info.plist ../GentleCompanion.app/Contents/

# Copy entitlements
cp GentleCompanion.entitlements ../GentleCompanion.app/Contents/

# Copy assets
cp -r Assets.xcassets/* ../GentleCompanion.app/Contents/Resources/Assets.xcassets/
cp -r Resources/* ../GentleCompanion.app/Contents/Resources/

# Set executable permission
chmod +x ../GentleCompanion.app/Contents/MacOS/GentleCompanion

# Sign the app (optional, but recommended)
echo "Signing the app..."
codesign --force --deep --sign - ../GentleCompanion.app

# Remove quarantine attribute
echo "Removing quarantine attribute..."
xattr -r -d com.apple.quarantine ../GentleCompanion.app

# Create DMG file
echo "Creating DMG file..."

# Create temporary DMG directory
mkdir -p ../dmg

# Copy app to DMG directory
cp -r ../GentleCompanion.app ../dmg/

# Create Applications symlink
ln -s /Applications ../dmg/Applications

# Create DMG
hdiutil create -fs HFS+ -srcfolder ../dmg -volname "GentleCompanion" ../GentleCompanion.dmg

# Clean up
rm -rf ../dmg

# Verify the app and DMG
echo "Verifying the app and DMG..."
if [ -f "../GentleCompanion.app/Contents/MacOS/GentleCompanion" ] && [ -f "../GentleCompanion.dmg" ]; then
    echo "Packaging completed successfully!"
    echo "App location: ../GentleCompanion.app"
    echo "DMG location: ../GentleCompanion.dmg"
    echo "You can now open the app by double-clicking it or install it from the DMG."
else
    echo "Packaging failed!"
    exit 1
fi
