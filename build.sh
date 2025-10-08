#!/bin/bash

echo "🚀 Starting build process for Mean Bot on Render..."

# Set error handling
set -e

# Update npm to latest version
echo "📦 Updating npm..."
npm install -g npm@latest || echo "⚠️  Could not update npm, continuing..."

# Clear npm cache to avoid conflicts
echo "🧹 Clearing npm cache..."
npm cache clean --force || echo "⚠️  Could not clear cache, continuing..."

# Install Node.js dependencies with clean install
echo "📦 Installing Node.js dependencies..."
if [ "$NODE_ENV" = "production" ]; then
    npm ci --only=production --verbose
else
    npm ci --verbose
fi

# Install Chromium for Puppeteer (CRITICAL for Render deployment)
echo "🌐 Installing Chromium for Puppeteer..."
echo "Cache directory: ${PUPPETEER_CACHE_DIR:-/opt/render/.cache/puppeteer}"

# Set Puppeteer cache directory environment variable
export PUPPETEER_CACHE_DIR=/opt/render/.cache/puppeteer

# Install Chrome using Puppeteer's built-in installer
echo "Installing Chrome browser for Puppeteer..."
npx puppeteer browsers install chrome || {
    echo "⚠️  npx method failed, trying alternative methods..."
    
    # Fallback: Use node to install via Puppeteer API
    node -e "
    const puppeteer = require('puppeteer');
    const fs = require('fs');
    
    (async () => {
      try {
        console.log('Attempting to install Chrome browser...');
        
        // Install browser using Puppeteer (this will handle the download)
        const execPath = await puppeteer.executablePath();
        console.log('✅ Puppeteer Chrome path:', execPath);
        
        // Verify it exists
        if (fs.existsSync(execPath)) {
          console.log('✅ Chrome executable verified at:', execPath);
        } else {
          console.log('❌ Chrome executable not found, attempting manual install...');
          process.exit(1);
        }
      } catch (error) {
        console.error('❌ Chrome installation failed:', error.message);
        process.exit(1);
      }
    })();
    " || {
        echo "⚠️  All methods failed, Chrome may not be available"
        exit 1
    }
}

# Verify Chromium installation
echo "🔍 Verifying Chromium installation..."

# Find Chrome executable recursively
CHROME_PATH=$(find /opt/render/.cache/puppeteer -name "chrome" -type f -executable 2>/dev/null | grep -E "chrome-linux|chrome-headless-shell" | head -n 1)

if [ -n "$CHROME_PATH" ]; then
    echo "✅ Chrome executable found at: $CHROME_PATH"
    
    # Test if it's actually executable
    if [ -x "$CHROME_PATH" ]; then
        echo "✅ Chrome is executable"
        $CHROME_PATH --version || echo "⚠️  Could not get Chrome version"
    else
        echo "⚠️  Chrome found but not executable, setting permissions..."
        chmod +x $CHROME_PATH
    fi
    
    # Export for use in the application
    export PUPPETEER_EXECUTABLE_PATH="$CHROME_PATH"
    echo "PUPPETEER_EXECUTABLE_PATH=$CHROME_PATH"
else
    echo "❌ Chrome executable not found!"
    echo "📂 Listing puppeteer cache contents:"
    find /opt/render/.cache/puppeteer -type f 2>/dev/null | head -20 || echo "No files found"
    
    echo "📂 Checking for Chrome in common locations:"
    ls -la /opt/render/.cache/puppeteer/chrome/ 2>/dev/null || echo "Chrome directory not found"
    
    exit 1
fi

echo "✅ Build completed successfully!"

echo "✅ Build completed successfully!"