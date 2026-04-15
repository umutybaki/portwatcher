#!/bin/bash
set -e

APP_NAME="PortWatcher"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

echo "Compiling Swift files..."
swiftc Sources/*.swift -o "$MACOS_DIR/$APP_NAME" -target arm64-apple-macosx13.0

echo "Copying Info.plist..."
cp Info.plist "$CONTENTS_DIR/"

echo "Build complete. App located at $APP_DIR"
