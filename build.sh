#!/bin/bash

echo "Starting build process for Mean Bot on Render..."

# Install Node.js dependencies with clean install
echo "Installing Node.js dependencies..."
npm ci

# Verify that critical dependencies are installed
echo "Verifying critical dependencies..."
node -e "
const deps = ['puppeteer', 'mongoose', 'node-telegram-bot-api'];
deps.forEach(dep => {
  try {
    require(dep);
    console.log('✅', dep, 'is available');
  } catch (err) {
    console.log('❌', dep, 'is missing');
    process.exit(1);
  }
});
"

echo "✅ Build completed successfully!"