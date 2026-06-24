#!/bin/bash

# Create DMG file for GentleCompanion app

echo "Creating DMG file for GentleCompanion..."

# Navigate to App directory
cd "$(dirname "$0")" || {
    echo "Directory not found!"
    exit 1
}

# Clean previous DMG
rm -rf GentleCompanion.dmg

# Create temporary DMG directory
mkdir -p dmg

# Build the app if it doesn't exist
if [ ! -d "GentleCompanion.app" ]; then
    echo "Building app..."
    cd GentleCompanion
    swift build -c release
    
    # Create app bundle structure
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
    
    # Sign the app
    codesign --force --deep --sign - ../GentleCompanion.app
    
    # Remove quarantine attribute
    xattr -r -d com.apple.quarantine ../GentleCompanion.app
    
    cd ..
fi

# Copy app to DMG directory
echo "Preparing DMG contents..."
cp -r GentleCompanion.app dmg/

# Create Applications symlink
ln -s /Applications dmg/Applications

# Create DMG
echo "Creating DMG file..."
hdiutil create -fs HFS+ -srcfolder dmg -volname "GentleCompanion" GentleCompanion.dmg

# Clean up
echo "Cleaning up..."
rm -rf dmg

# Verify the DMG
if [ -f "GentleCompanion.dmg" ]; then
    echo "DMG creation completed successfully!"
    echo "DMG location: GentleCompanion.dmg"
    echo "You can now install the app from the DMG."
else
    echo "DMG creation failed!"
    exit 1
fi