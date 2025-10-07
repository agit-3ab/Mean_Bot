#!/bin/bash

echo "Starting build process for Mean Bot on Render..."

# Update system packages
apt-get update

# Install Chrome dependencies for Puppeteer on Render
echo "Installing Chrome and dependencies..."
apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    procps \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libgtk-3-0 \
    libgtk-4-1 \
    libnss3 \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    && rm -rf /var/lib/apt/lists/*

# Verify Chrome installation
if command -v google-chrome-stable > /dev/null; then
    echo "✅ Chrome installed successfully"
    google-chrome-stable --version
else
    echo "❌ Chrome installation failed"
    exit 1
fi

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

echo "✅ Build completed successfully!"