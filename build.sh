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

echo "✅ Build completed successfully!"