#!/bin/bash

# Create app bundle and DMG for GentleCompanion

echo "Creating app bundle and DMG for GentleCompanion..."

# Navigate to App directory
cd "$(dirname "$0")" || {
    echo "Directory not found!"
    exit 1
}

# Clean previous files
rm -rf GentleCompanion.app
rm -rf GentleCompanion.dmg
rm -rf dmg/

# Create app bundle structure
echo "Creating app bundle structure..."
mkdir -p GentleCompanion.app/Contents/MacOS
mkdir -p GentleCompanion.app/Contents/Resources
mkdir -p GentleCompanion.app/Contents/Resources/Assets.xcassets

# Copy executable
echo "Copying executable..."
cp GentleCompanion/.build/x86_64-apple-macosx/release/GentleCompanion GentleCompanion.app/Contents/MacOS/

# Copy Info.plist
echo "Copying Info.plist..."
cp GentleCompanion/Info.plist GentleCompanion.app/Contents/

# Copy entitlements
echo "Copying entitlements..."
cp GentleCompanion/GentleCompanion.entitlements GentleCompanion.app/Contents/

# Copy assets
echo "Copying assets..."
cp -r GentleCompanion/Assets.xcassets/* GentleCompanion.app/Contents/Resources/Assets.xcassets/
cp -r GentleCompanion/Resources/* GentleCompanion.app/Contents/Resources/

# Set executable permission
echo "Setting permissions..."
chmod +x GentleCompanion.app/Contents/MacOS/GentleCompanion

# Sign the app
echo "Signing the app..."
codesign --force --deep --sign - GentleCompanion.app

# Remove quarantine attribute
echo "Removing quarantine attribute..."
xattr -r -d com.apple.quarantine GentleCompanion.app

# Create DMG
echo "Creating DMG..."
mkdir -p dmg
cp -r GentleCompanion.app dmg/
ln -s /Applications dmg/Applications
hdiutil create -fs HFS+ -srcfolder dmg -volname "GentleCompanion" GentleCompanion.dmg

# Clean up
echo "Cleaning up..."
rm -rf dmg/

# Verify
echo "Verification..."
if [ -f "GentleCompanion.app/Contents/MacOS/GentleCompanion" ] && [ -f "GentleCompanion.dmg" ]; then
    echo "Success!"
    echo "App bundle: GentleCompanion.app"
    echo "DMG file: GentleCompanion.dmg"
else
    echo "Failed!"
    exit 1
fi