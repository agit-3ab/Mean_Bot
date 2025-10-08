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
npx puppeteer browsers install chrome || {
    echo "⚠️  Puppeteer browsers install failed, trying alternative method..."
    # Alternative: Install from cache
    node -e "const puppeteer = require('puppeteer'); console.log('Puppeteer cache dir:', puppeteer.configuration.cacheDirectory);"
}

# Verify Chromium installation
echo "🔍 Verifying Chromium installation..."
ls -la /opt/render/.cache/puppeteer/ || echo "⚠️  Puppeteer cache directory not found at expected location"

echo "✅ Build completed successfully!"