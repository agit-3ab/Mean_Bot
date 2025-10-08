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

# Install Chrome using Puppeteer's built-in installer with specific version
echo "Installing Chrome browser for Puppeteer..."

# Method 1: Try installing with @puppeteer/browsers (preferred for Puppeteer 22+)
npx @puppeteer/browsers install chrome@stable --path /opt/render/.cache/puppeteer && {
    echo "✅ Chrome installed successfully with @puppeteer/browsers"
} || {
    echo "⚠️  @puppeteer/browsers method failed, trying alternative..."
    
    # Method 2: Use Puppeteer's own installer
    npx puppeteer browsers install chrome --path /opt/render/.cache/puppeteer || {
        echo "⚠️  Standard method failed, trying node script..."
        
        # Method 3: Use node to install via Puppeteer API
        node -e "
        const puppeteer = require('puppeteer');
        const fs = require('fs');
        
        (async () => {
          try {
            console.log('Attempting to download Chrome browser...');
            
            // Try to get the browser fetcher
            const browserFetcher = puppeteer.createBrowserFetcher({
              path: '/opt/render/.cache/puppeteer'
            });
            
            console.log('Downloading Chrome...');
            const revisionInfo = await browserFetcher.download('127.0.6533.88');
            
            console.log('✅ Chrome downloaded to:', revisionInfo.executablePath);
            
            // Verify it exists
            if (fs.existsSync(revisionInfo.executablePath)) {
              console.log('✅ Chrome executable verified');
              fs.chmodSync(revisionInfo.executablePath, '755');
            } else {
              console.log('❌ Chrome executable not found after download');
              process.exit(1);
            }
          } catch (error) {
            console.error('❌ Chrome installation failed:', error.message);
            console.log('Attempting fallback installation...');
            
            // Last resort: try default installation
            try {
              const execPath = puppeteer.executablePath();
              console.log('Using default Chrome path:', execPath);
            } catch (e) {
              console.error('All installation methods failed');
              process.exit(1);
            }
          }
        })();
        " || {
            echo "❌ All Chrome installation methods failed"
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