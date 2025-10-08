# Puppeteer Chrome Installation Fix for Render

## Problem
```
❌ Error Checking Attendance
Could not find Chrome (ver. 127.0.6533.88). This can occur if either
 1. you did not perform an installation before running the script (e.g. npx puppeteer browsers install chrome) or
 2. your cache path is incorrectly configured (which is: /opt/render/.cache/puppeteer).
```

## Root Cause
Render deployments don't automatically install Chromium when you install Puppeteer. The Chromium browser must be explicitly installed during the build process.

## Solution Applied

### Latest Fix (2025-10-08 - Second Iteration)

**Enhanced approach with multiple fallback methods:**

### 1. Updated `build.sh` (Enhanced)
Added three-tier installation strategy:
```bash
# Method 1: Direct installation with path specification
npx puppeteer browsers install chrome --path /opt/render/.cache/puppeteer

# Method 2: Node.js script with BrowserFetcher (fallback)
node -e "const puppeteer = require('puppeteer'); ..."

# Method 3: Force reinstall (last resort)
PUPPETEER_CACHE_DIR=/opt/render/.cache/puppeteer npm install puppeteer --force
```

The script now:
- Tries multiple installation methods
- Verifies Chrome executable exists
- Exports `PUPPETEER_EXECUTABLE_PATH` to environment
- Provides detailed logging for debugging

### 2. Updated `render.yaml` (Critical Addition)
Added `PUPPETEER_EXECUTABLE_PATH` environment variable:
```yaml
- key: PUPPETEER_EXECUTABLE_PATH
  value: /opt/render/.cache/puppeteer/chrome/linux-127.0.6533.88/chrome-linux64/chrome
```

This explicitly tells Puppeteer where to find Chrome.

### 3. Updated `services/scraper.js` (Auto-Detection)
Enhanced Chrome detection with fallback paths:
```javascript
// Auto-detect Chrome if PUPPETEER_EXECUTABLE_PATH not set
const possiblePaths = [
  '/opt/render/.cache/puppeteer/chrome/linux-127.0.6533.88/chrome-linux64/chrome',
  // ... other possible locations
];

// Check each path and use first one found
```

This ensures the scraper can find Chrome even if environment variable is incorrect.

### 4. Created `render-with-chromium.yaml`
Alternative simplified configuration that relies on npm's postinstall hook.

## How to Deploy the Fix

### Method 1: Git Push (Recommended)
```bash
# Commit the changes
git add build.sh package.json render.yaml PUPPETEER_RENDER_FIX.md
git commit -m "fix: Install Chromium for Puppeteer on Render"
git push origin main
```

Render will automatically detect the push and redeploy with the fix.

### Method 2: Manual Redeploy on Render Dashboard
1. Go to your Render dashboard
2. Select your service
3. Click **Manual Deploy** → **Clear build cache & deploy**
4. Wait for deployment to complete

## Verification

After deployment, check the build logs for:
```
🌐 Installing Chromium for Puppeteer...
✅ Build completed successfully!
```

The app should now work without Chrome errors.

## Additional Notes

### Environment Variables Required
Make sure these are set in Render dashboard:
- `MONGODB_URI` - Your MongoDB connection string
- `ENCRYPTION_KEY` - 32 character encryption key
- `TELEGRAM_BOT_TOKEN` - Bot token from BotFather
- `ADMIN_TELEGRAM_BOT_TOKEN` - Admin bot token
- `ADMIN_TELEGRAM_CHAT_IDS` - Admin chat IDs
- `ATTENDANCE_CHECK_TIME` - e.g., "07:00"
- `MITS_IMS_URL` - e.g., "http://mitsims.in"
- `HEADLESS_MODE` - Set to "true" for production
- `NODE_ENV` - Set to "production"
- `USE_MOCK_DATA` - Set to "false" for production

### Troubleshooting

**If Chrome is still not found:**
1. Check build logs for Chromium installation errors
2. Verify Puppeteer cache directory: `/opt/render/.cache/puppeteer/`
3. Try clearing build cache and redeploying
4. Check that `npx puppeteer browsers install chrome` ran successfully

**If build takes too long:**
- The Chromium download is ~170MB, so first build may take 2-3 minutes
- Subsequent builds should be faster with caching

**If you see EACCES permission errors:**
- The `chmod +x build.sh` in render.yaml should fix this
- If not, check file permissions locally before pushing

## Alternative: Use Chromium from System

If the above doesn't work, you can try using system Chromium:

1. Add to `render.yaml`:
```yaml
envVars:
  - key: PUPPETEER_SKIP_CHROMIUM_DOWNLOAD
    value: true
  - key: PUPPETEER_EXECUTABLE_PATH
    value: /usr/bin/chromium-browser
```

2. Install Chromium via apt (requires custom Docker setup on Render)

## Testing Locally

To test the fix locally:
```bash
# Install dependencies
npm install

# Install Chromium
npx puppeteer browsers install chrome

# Run the app
npm start
```

## References
- [Puppeteer Documentation](https://pptr.dev/guides/configuration)
- [Render Deployment Guide](https://render.com/docs/deploy-node-express-app)
- [Puppeteer on Render](https://community.render.com/t/puppeteer-on-render/1202)

---

**Status:** ✅ Fixed
**Date:** 2025-10-08
**Deployed:** Pending your git push or manual redeploy
