# Telegram 409 Conflict & Chrome Installation Fix

## Issues Fixed

### 1. Telegram 409 Conflict Error
**Problem:** Multiple bot instances trying to poll simultaneously
**Error:** `ETELEGRAM: 409 Conflict: terminated by other getUpdates request`

### 2. Chrome/Puppeteer Not Found
**Problem:** Chrome executable not found during runtime
**Error:** `Could not find Chrome (ver. 127.0.6533.88)`

## Changes Made

### A. Telegram Service Fixes (`services/telegramService.js` & `services/adminTelegramService.js`)

#### 1. Added Webhook Cleanup on Startup
- Both bot services now delete any existing webhooks before starting polling
- This prevents conflicts from previous instances or webhook configurations

#### 2. Implemented Polling Error Handling
- Added `polling_error` event handler
- Automatic detection of 409 conflicts
- Recovery mechanism that:
  - Stops current polling
  - Deletes webhook again
  - Waits 2 seconds
  - Restarts polling

#### 3. Enhanced Polling Configuration
```javascript
polling: {
  interval: 300,           // Check every 300ms
  autoStart: true,
  params: {
    timeout: 10            // 10 second timeout
  }
}
```

### B. Build Script Fixes (`build.sh`)

#### 1. Multiple Chrome Installation Methods
Now tries 3 different methods in sequence:

1. **@puppeteer/browsers** (preferred for Puppeteer 22+)
   ```bash
   npx @puppeteer/browsers install chrome@stable
   ```

2. **Standard Puppeteer installer**
   ```bash
   npx puppeteer browsers install chrome
   ```

3. **Node.js script fallback**
   - Uses Puppeteer's browserFetcher API
   - Downloads specific Chrome version (127.0.6533.88)
   - Sets proper permissions

#### 2. Enhanced Chrome Verification
- Searches for multiple possible executable names:
  - `chrome`
  - `chromium`
  - `chrome-headless-shell`
- Checks multiple path patterns
- Saves Chrome path to `chrome_path.txt` for runtime use

#### 3. Better Error Reporting
- Lists cache directory contents on failure
- Shows directory structure
- Provides clear error messages

### C. Scraper Service Fixes (`services/scraper.js`)

#### 1. Multi-Method Chrome Detection
Added 4 methods to find Chrome executable:

**Method 0: Read Saved Path**
- Reads `chrome_path.txt` created during build
- Fastest method if file exists

**Method 1: Find Command**
- Searches entire cache directory
- Looks for multiple executable names
```bash
find /opt/render/.cache/puppeteer -type f -executable \
  \( -name "chrome" -o -name "chromium" -o -name "chrome-headless-shell" \)
```

**Method 2: Recursive Directory Search**
- Intelligently searches Chrome directories
- Checks multiple subdirectory patterns:
  - `chrome-linux64/chrome`
  - `chrome-linux/chrome`
  - `chromium-linux/chromium`
- Verifies executable permissions

**Method 3: Puppeteer Default**
- Falls back to Puppeteer's built-in path detection

## Deployment Steps

### 1. Stop All Running Instances

**On Render:**
1. Go to your Render dashboard
2. Click on your service
3. Click "Manual Deploy" → "Clear build cache & deploy"
   - This ensures a fresh build with new Chrome installation

**Or restart manually:**
```bash
# In Render shell or via Render dashboard
pm2 stop all  # If using PM2
# Or just redeploy the service
```

### 2. Verify Environment Variables

Make sure these are set in Render dashboard:

```bash
# Required for both bots
TELEGRAM_BOT_TOKEN=your_user_bot_token
ADMIN_TELEGRAM_BOT_TOKEN=your_admin_bot_token
ADMIN_TELEGRAM_CHAT_IDS=123456789,987654321

# Puppeteer settings
NODE_ENV=production
PUPPETEER_CACHE_DIR=/opt/render/.cache/puppeteer
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
HEADLESS_MODE=true

# Optional - will be auto-detected
PUPPETEER_EXECUTABLE_PATH=/opt/render/.cache/puppeteer/chrome/...
```

### 3. Deploy with New Build

1. Push changes to GitHub:
   ```bash
   git add .
   git commit -m "Fix Telegram 409 and Chrome installation issues"
   git push origin main
   ```

2. Render will automatically deploy, or manually trigger deploy

3. Monitor the build logs to ensure:
   - ✅ Chrome installation succeeds
   - ✅ Chrome executable is found and verified
   - ✅ Chrome path is saved to chrome_path.txt

4. Monitor the runtime logs to ensure:
   - ✅ Webhooks are deleted on startup
   - ✅ Both bots initialize successfully
   - ✅ No 409 errors appear
   - ✅ Chrome is found and launches successfully

### 4. Testing

After deployment, test both issues are fixed:

**Test Telegram Bots:**
1. Send `/start` to your user bot
2. Send `/help` to your admin bot
3. Verify no 409 errors in logs

**Test Chrome/Scraper:**
1. Send `/check` command to user bot with a student ID
2. Verify Chrome launches successfully
3. Check that attendance is fetched properly

## Troubleshooting

### Still Getting 409 Errors?

1. **Check for webhook on Telegram side:**
   ```bash
   curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo
   ```

2. **Manually delete webhook:**
   ```bash
   curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/deleteWebhook
   ```

3. **Ensure no duplicate deployments:**
   - Check you don't have the bot running elsewhere
   - Verify only one Render service is running
   - Check local development instances are stopped

### Chrome Still Not Found?

1. **Check build logs:**
   - Look for Chrome installation step
   - Verify no errors during download
   - Check that Chrome path is printed

2. **Manual verification in Render shell:**
   ```bash
   find /opt/render/.cache/puppeteer -name "chrome" -type f
   ls -la /opt/render/.cache/puppeteer/chrome/
   ```

3. **Check disk space:**
   - Chrome needs ~150MB
   - Verify Render plan has enough space

4. **Try specific Chrome version:**
   - Add to `package.json` devDependencies:
     ```json
     "@puppeteer/browsers": "^1.9.0"
     ```

### Emergency Fixes

**If bots still conflict:**
1. Add unique session names:
   ```javascript
   // In constructor
   this.bot = new TelegramBot(this.botToken, { 
     polling: {
       interval: 300,
       autoStart: true,
       params: {
         timeout: 10
       }
     },
     filepath: false  // Disable local polling lock file
   });
   ```

**If Chrome still fails:**
1. Use environment variable override:
   ```bash
   PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome
   ```

2. Or install system Chrome in `render.yaml`:
   ```yaml
   buildCommand: |
     apt-get update && apt-get install -y chromium
     chmod +x build.sh && ./build.sh
   ```

## Monitoring

After deployment, monitor these metrics:

1. **Bot Health:**
   - No repeated 409 errors
   - Messages are received and responded to
   - Admin commands work

2. **Scraper Health:**
   - Chrome launches successfully
   - Attendance checks complete
   - No "Chrome not found" errors

3. **System Health:**
   - Memory usage is stable
   - No crash loops
   - Heartbeat is regular

## Success Indicators

✅ **Fixed Successfully When:**
- No 409 errors in logs
- Both bots respond to commands
- Chrome launches on first attempt
- Attendance checks complete successfully
- No repeated restarts or crashes

## Additional Notes

- The fixes are backward compatible
- No breaking changes to existing functionality
- Recovery is automatic if errors occur
- Build process is more robust with fallbacks
