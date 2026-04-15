#!/bin/bash
set -e

APP_NAME="PortWatcher"
DMG_NAME="${APP_NAME}.dmg"

echo "🚀 Starting release process..."

# 1. Build the app
chmod +x build.sh
./build.sh

echo "📦 Preparing DMG Staging..."
STAGING_DIR="build/dmg_staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Copy App to staging
cp -R "build/${APP_NAME}.app" "$STAGING_DIR/"

# Create symlink to /Applications
ln -s /Applications "$STAGING_DIR/Applications"

echo "📦 Packaging into Disk Image (.dmg)..."

# 2. Create the DMG from the staging directory
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

# Clean up staging
rm -rf "$STAGING_DIR"

echo "-----------------------------------------------"
echo "✅ Build Successful!"
echo "Release package created: ${DMG_NAME}"
echo ""
echo "Next Steps:"
echo "1. Create a new release tag on GitHub: git tag -a v1.0.0 -m 'Release v1.0.0' && git push origin v1.0.0"
echo "2. Upload ${DMG_NAME} to the GitHub Release assets."
echo "-----------------------------------------------"
