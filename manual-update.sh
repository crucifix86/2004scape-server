#!/bin/bash

# Manual update script for VPS installations
echo "=== Manual Update to Latest Version ==="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "src/website" ]; then
    echo "Error: This script must be run from the 2004scape-server directory"
    exit 1
fi

echo "Creating backup..."
cd ..
tar --exclude='node_modules' --exclude='.git' --exclude='*.log' --exclude='*.pid' -czf "manual-update-backup-$(date +%Y%m%d-%H%M%S).tar.gz" 2004scape-server

echo "Downloading latest version..."
cd 2004scape-server

# Download specific files that need updating
echo "Updating server.ts..."
wget -O src/website/server.ts https://raw.githubusercontent.com/crucifix86/2004scape-server/main/src/website/server.ts

echo "Updating package.json..."
wget -O package.json https://raw.githubusercontent.com/crucifix86/2004scape-server/main/package.json

echo "Building project..."
npm run build

echo ""
echo "=== Update Complete! ==="
echo "Version updated to latest"
echo "Please restart the server:"
echo "./server restart"