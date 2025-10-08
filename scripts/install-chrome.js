#!/usr/bin/env node

/**
 * Post-install script to ensure Chrome is available for Puppeteer
 * This runs automatically after npm install
 */

const fs = require('fs');
const path = require('path');

console.log('🔍 Checking Chrome installation for Puppeteer...');

// Only run in production environment (Render)
if (process.env.NODE_ENV !== 'production') {
  console.log('⏭️  Skipping Chrome installation (not in production)');
  process.exit(0);
}

(async () => {
  try {
    const puppeteer = require('puppeteer');
    const cacheDir = process.env.PUPPETEER_CACHE_DIR || path.join(__dirname, '../.cache/puppeteer');
    
    console.log(`📂 Using cache directory: ${cacheDir}`);
    
    // Ensure cache directory exists
    if (!fs.existsSync(cacheDir)) {
      fs.mkdirSync(cacheDir, { recursive: true });
      console.log('✅ Created cache directory');
    }
    
    // Try to get Chrome executable path
    let chromePath = null;
    
    try {
      chromePath = puppeteer.executablePath();
      console.log(`🔍 Found bundled Chrome at: ${chromePath}`);
      
      // Verify it exists
      if (fs.existsSync(chromePath)) {
        console.log('✅ Chrome executable verified');
        
        // Save the path for runtime use
        const pathFile = path.join(cacheDir, 'chrome_path.txt');
        fs.writeFileSync(pathFile, chromePath);
        console.log(`✅ Chrome path saved to: ${pathFile}`);
        
        process.exit(0);
      } else {
        console.log('⚠️  Chrome path reported but file not found');
        chromePath = null;
      }
    } catch (error) {
      console.log('⚠️  No bundled Chrome found:', error.message);
    }
    
    // If we get here, Chrome needs to be installed
    console.log('📥 Installing Chrome for Puppeteer...');
    
    // For Puppeteer v22+, use BrowserFetcher
    try {
      const browserFetcher = puppeteer.createBrowserFetcher({
        path: cacheDir,
        platform: 'linux'
      });
      
      console.log('📥 Downloading Chrome browser (this may take a few minutes)...');
      
      // Use a stable Chrome revision that works with Puppeteer 22
      // Revision 1134945 corresponds to Chrome 120
      const revisionInfo = await browserFetcher.download('1134945');
      
      console.log('✅ Chrome downloaded successfully');
      console.log(`✅ Chrome executable: ${revisionInfo.executablePath}`);
      
      // Make it executable
      if (fs.existsSync(revisionInfo.executablePath)) {
        fs.chmodSync(revisionInfo.executablePath, 0o755);
        console.log('✅ Chrome permissions set');
        
        // Save the path
        const pathFile = path.join(cacheDir, 'chrome_path.txt');
        fs.writeFileSync(pathFile, revisionInfo.executablePath);
        console.log(`✅ Chrome path saved to: ${pathFile}`);
        
        console.log('🎉 Chrome installation completed successfully!');
        process.exit(0);
      } else {
        throw new Error('Chrome executable not found after download');
      }
      
    } catch (fetchError) {
      console.error('❌ Failed to download Chrome:', fetchError.message);
      
      // Try alternative: check if system Chrome/Chromium is available
      console.log('🔍 Checking for system Chromium...');
      
      const { execSync } = require('child_process');
      try {
        const systemChrome = execSync('which chromium-browser || which chromium || which google-chrome', 
          { encoding: 'utf8' }).trim();
        
        if (systemChrome && fs.existsSync(systemChrome)) {
          console.log(`✅ Found system Chrome: ${systemChrome}`);
          
          const pathFile = path.join(cacheDir, 'chrome_path.txt');
          fs.writeFileSync(pathFile, systemChrome);
          console.log('✅ Using system Chrome');
          
          process.exit(0);
        }
      } catch (e) {
        console.log('⚠️  No system Chrome found');
      }
      
      console.error('❌ Chrome installation failed!');
      console.error('The application may not work correctly without Chrome.');
      console.error('You can manually set PUPPETEER_EXECUTABLE_PATH environment variable.');
      
      // Don't fail the build, just warn
      process.exit(0);
    }
    
  } catch (error) {
    console.error('❌ Error during Chrome installation:', error.message);
    console.error(error.stack);
    
    // Don't fail npm install, just warn
    console.warn('⚠️  Chrome installation failed, but continuing...');
    process.exit(0);
  }
})();
