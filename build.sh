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
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# Ensure cache directory exists
mkdir -p /opt/render/.cache/puppeteer

# Install Chrome using Puppeteer's built-in installer
echo "Installing Chrome browser for Puppeteer v22..."

# For Puppeteer v22+, Chrome should be installed automatically during npm install
# But we'll verify and install if needed

# First, check if Puppeteer already has Chrome
echo "🔍 Checking if Puppeteer has Chrome bundled..."
node -e "
const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  try {
    // Try to get bundled Chrome path
    const browserPath = puppeteer.executablePath();
    console.log('Checking bundled Chrome at:', browserPath);
    
    if (fs.existsSync(browserPath)) {
      console.log('✅ Puppeteer bundled Chrome found');
      console.log('Path:', browserPath);
      
      // Save this path for runtime
      const cacheDir = process.env.PUPPETEER_CACHE_DIR || '/opt/render/.cache/puppeteer';
      fs.mkdirSync(cacheDir, { recursive: true });
      fs.writeFileSync(cacheDir + '/chrome_path.txt', browserPath);
      console.log('✅ Chrome path saved');
      process.exit(0);
    } else {
      console.log('⚠️  Bundled Chrome not found, need to install manually');
      process.exit(1);
    }
  } catch (error) {
    console.log('⚠️  Error checking bundled Chrome:', error.message);
    process.exit(1);
  }
})();
" || {
    echo "⚠️  Bundled Chrome not found, installing manually..."
    
    # Method 1: Use node script to download Chrome
    node -e "
    const puppeteer = require('puppeteer');
    const fs = require('fs');
    const https = require('https');
    const path = require('path');
    
    (async () => {
      try {
        const cacheDir = process.env.PUPPETEER_CACHE_DIR || '/opt/render/.cache/puppeteer';
        console.log('Installing Chrome to:', cacheDir);
        
        // For Puppeteer 22+, we need to use the new BrowserFetcher
        const {Browser} = puppeteer;
        
        // Try using puppeteer-core's built-in Chrome downloader
        const browserFetcher = puppeteer.createBrowserFetcher({
          path: cacheDir,
          platform: 'linux',
        });
        
        console.log('📥 Downloading Chrome (this may take a few minutes)...');
        
        // Download latest revision
        const revisionInfo = await browserFetcher.download('1134945');
        
        console.log('✅ Chrome downloaded successfully');
        console.log('Executable path:', revisionInfo.executablePath);
        
        // Make it executable
        if (fs.existsSync(revisionInfo.executablePath)) {
          fs.chmodSync(revisionInfo.executablePath, 0o755);
          console.log('✅ Chrome executable permissions set');
          
          // Save path for runtime
          fs.writeFileSync(path.join(cacheDir, 'chrome_path.txt'), revisionInfo.executablePath);
          console.log('✅ Chrome path saved');
        }
        
      } catch (error) {
        console.error('❌ Chrome installation failed:', error.message);
        console.error(error);
        process.exit(1);
      }
    })();
    " || {
        echo "❌ All Chrome installation methods failed"
        echo "Trying system Chromium installation..."
        
        # Last resort: try to use system Chromium if available
        which chromium-browser && {
            SYSTEM_CHROME=$(which chromium-browser)
            echo "✅ Found system Chromium: $SYSTEM_CHROME"
            echo "$SYSTEM_CHROME" > /opt/render/.cache/puppeteer/chrome_path.txt
        } || {
            echo "❌ No Chromium installation found"
            exit 1
        }
    }
}

# Verify Chromium installation
echo "🔍 Verifying Chromium installation..."

# Find Chrome executable recursively - look for multiple possible names
CHROME_PATH=$(find /opt/render/.cache/puppeteer -type f -executable \( -name "chrome" -o -name "chromium" -o -name "chrome-headless-shell" \) 2>/dev/null | head -n 1)

if [ -z "$CHROME_PATH" ]; then
    # If not found by name, try to find by path pattern
    echo "🔍 Chrome not found by name, searching by path pattern..."
    CHROME_PATH=$(find /opt/render/.cache/puppeteer -path "*/chrome-linux*/chrome" -type f 2>/dev/null | head -n 1)
fi

if [ -z "$CHROME_PATH" ]; then
    # Try headless shell as fallback
    echo "🔍 Trying chrome-headless-shell..."
    CHROME_PATH=$(find /opt/render/.cache/puppeteer -path "*/chrome-headless-shell-linux*/chrome-headless-shell" -type f 2>/dev/null | head -n 1)
fi

if [ -n "$CHROME_PATH" ]; then
    echo "✅ Chrome executable found at: $CHROME_PATH"
    
    # Make sure it's executable
    chmod +x "$CHROME_PATH" 2>/dev/null || echo "⚠️  Could not set executable permission (may already be set)"
    
    # Test if it's actually executable and get version
    if [ -x "$CHROME_PATH" ]; then
        echo "✅ Chrome is executable"
        $CHROME_PATH --version 2>/dev/null || echo "⚠️  Could not get Chrome version (may still work)"
    else
        echo "⚠️  Chrome found but not executable, attempting to fix permissions..."
        chmod 755 "$CHROME_PATH"
    fi
    
    # Export for use in the application
    export PUPPETEER_EXECUTABLE_PATH="$CHROME_PATH"
    echo "✅ PUPPETEER_EXECUTABLE_PATH=$CHROME_PATH"
    
    # Also create a file with the path for runtime use
    echo "$CHROME_PATH" > /opt/render/.cache/puppeteer/chrome_path.txt
    echo "✅ Chrome path saved to chrome_path.txt"
else
    echo "❌ Chrome executable not found!"
    echo "📂 Listing puppeteer cache contents:"
    find /opt/render/.cache/puppeteer -type f 2>/dev/null | head -30 || echo "No files found"
    
    echo "📂 Checking directory structure:"
    ls -la /opt/render/.cache/puppeteer/ 2>/dev/null || echo "Cache directory not accessible"
    
    echo "❌ Chrome installation failed - build cannot continue"
    exit 1
fi

echo "✅ Build completed successfully!"

echo "✅ Build completed successfully!"