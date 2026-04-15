#!/bin/bash
set -e

# Run the build script to generate the .app bundle
chmod +x build.sh
./build.sh

echo "-----------------------------------------------"
echo "Installing PortWatcher to /Applications..."
echo "-----------------------------------------------"

# Remove existing installation if it exists
if [ -d "/Applications/PortWatcher.app" ]; then
    echo "Updating existing installation..."
    rm -rf "/Applications/PortWatcher.app"
fi

# Copy the new build to /Applications
cp -R build/PortWatcher.app /Applications/

echo "Success! PortWatcher has been installed to /Applications."
echo "Launching PortWatcher..."

# Launch the app
open /Applications/PortWatcher.app

echo "Installation complete. Look for the network icon in your menubar!"
