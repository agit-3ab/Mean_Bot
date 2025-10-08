#!/bin/bash

echo "🚀 Starting build process for Mean Bot on Render..."

# Set error handling
set -e

# Install Node.js dependencies with clean install
echo "📦 Installing Node.js dependencies..."
if [ "$NODE_ENV" = "production" ]; then
    npm ci --only=production
else
    npm ci
fi

# Install system dependencies only if we're running as root (typically in Docker/Render)
if [ "$EUID" -eq 0 ] 2>/dev/null; then
    echo "🔧 Installing system dependencies for Puppeteer..."
    apt-get update > /dev/null 2>&1 || echo "⚠️  Could not update package list"
    apt-get install -y \
        fonts-liberation \
        libappindicator3-1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libdrm2 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libx11-xcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        xdg-utils \
        libxss1 \
        libgconf-2-4 > /dev/null 2>&1 || echo "⚠️  Some system packages couldn't be installed, continuing..."
else
    echo "ℹ️  Skipping system package installation (not running as root)"
fi

# Verify that critical Node.js dependencies are available
echo "✅ Verifying critical dependencies..."
node -e "
const deps = ['puppeteer', 'mongoose', 'node-telegram-bot-api', 'dotenv'];
let allGood = true;
deps.forEach(dep => {
  try {
    require(dep);
    console.log('✅', dep, 'is available');
  } catch (err) {
    console.log('❌', dep, 'is missing:', err.message);
    allGood = false;
  }
});
if (!allGood) {
  console.log('❌ Some dependencies are missing');
  process.exit(1);
}
console.log('🎉 All dependencies verified successfully!');
"

echo "✅ Build completed successfully!"