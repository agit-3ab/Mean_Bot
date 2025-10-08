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

# Method 1: Use npx puppeteer browsers install
echo "Attempting Method 1: npx puppeteer browsers install chrome..."
npx puppeteer browsers install chrome --path /opt/render/.cache/puppeteer || {
    echo "⚠️  Method 1 failed, trying Method 2..."
    
    # Method 2: Use node script to download browser
    echo "Attempting Method 2: Node.js script..."
    node -e "
    const puppeteer = require('puppeteer');
    (async () => {
      try {
        const browserFetcher = puppeteer.createBrowserFetcher({ path: '/opt/render/.cache/puppeteer' });
        const revisionInfo = await browserFetcher.download('1134058');
        console.log('✅ Chromium downloaded to:', revisionInfo.executablePath);
      } catch (error) {
        console.error('❌ Download failed:', error.message);
        process.exit(1);
      }
    })();
    " || {
        echo "⚠️  Method 2 failed, trying Method 3..."
        
        # Method 3: Force reinstall puppeteer with browser
        echo "Attempting Method 3: Reinstall Puppeteer..."
        PUPPETEER_CACHE_DIR=/opt/render/.cache/puppeteer npm install puppeteer --force
    }
}

# Verify Chromium installation
echo "🔍 Verifying Chromium installation..."
if [ -d "/opt/render/.cache/puppeteer" ]; then
    echo "✅ Puppeteer cache directory exists"
    ls -la /opt/render/.cache/puppeteer/ || true
    
    # Find Chrome executable
    CHROME_PATH=$(find /opt/render/.cache/puppeteer -name chrome -type f 2>/dev/null | head -n 1)
    if [ -n "$CHROME_PATH" ]; then
        echo "✅ Chrome executable found at: $CHROME_PATH"
        echo "PUPPETEER_EXECUTABLE_PATH=$CHROME_PATH" >> $HOME/.profile
    else
        echo "⚠️  Chrome executable not found!"
        echo "Listing all files in puppeteer cache:"
        find /opt/render/.cache/puppeteer -type f 2>/dev/null || true
    fi
else
    echo "❌ Puppeteer cache directory not found at /opt/render/.cache/puppeteer"
    exit 1
fi

echo "✅ Build completed successfully!"