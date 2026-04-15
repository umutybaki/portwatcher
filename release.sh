#!/bin/bash
set -e

APP_NAME="PortWatcher"
DMG_NAME="${APP_NAME}.dmg"

echo "🚀 Starting release process..."

# 1. Build the app
chmod +x build.sh
./build.sh

echo "📦 Packaging into Disk Image (.dmg)..."

# 2. Create the DMG
# -volname: Name of the mounted volume
# -srcfolder: Path to the .app bundle
# -ov: Overwrite existing DMG
# -format UDZO: Compressed image format
hdiutil create -volname "$APP_NAME" -srcfolder "build/${APP_NAME}.app" -ov -format UDZO "$DMG_NAME"

echo "-----------------------------------------------"
echo "✅ Build Successful!"
echo "Release package created: ${DMG_NAME}"
echo ""
echo "Next Steps:"
echo "1. Create a new release tag on GitHub: git tag -a v1.0.0 -m 'Release v1.0.0' && git push origin v1.0.0"
echo "2. Upload ${DMG_NAME} to the GitHub Release assets."
echo "-----------------------------------------------"
