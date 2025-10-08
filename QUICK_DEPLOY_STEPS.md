# Quick Deployment Steps - Chrome Fix

## What Was Fixed
✅ Chrome installation path detection
✅ Dynamic Chrome version support
✅ Better error handling for missing Chrome
✅ Removed hardcoded version paths

## Deploy Now (3 Steps)

### 1. Commit Changes
```bash
git add .
git commit -m "Fix: Chrome installation for Render deployment"
git push origin main
```

### 2. Trigger Render Deploy
- Go to Render Dashboard
- Click "Manual Deploy" or wait for auto-deploy
- Monitor the build logs

### 3. Watch for Success
**Build logs should show:**
```
🌐 Installing Chromium for Puppeteer...
✅ Chrome executable found at: /opt/render/.cache/puppeteer/chrome/...
✅ Build completed successfully!
```

**Runtime logs should show:**
```
✅ Found Chrome at: /opt/render/.cache/puppeteer/...
🚀 Launching browser...
```

## If It Still Fails

### Option A: Clear Render Cache
1. Go to Render Dashboard → Your Service
2. Settings → "Clear build cache"
3. Trigger new deploy

### Option B: Add System Chrome
Update `render.yaml` buildCommand to:
```yaml
buildCommand: |
  apt-get update && apt-get install -y chromium-browser && 
  chmod +x build.sh && ./build.sh
```

Then add env var in Render Dashboard:
- `PUPPETEER_EXECUTABLE_PATH` = `/usr/bin/chromium-browser`

## Environment Variables Needed
Set these in Render Dashboard (if not already set):

**Required:**
- `TELEGRAM_BOT_TOKEN` - Your bot token
- `ENCRYPTION_KEY` - 32 character key
- `MITS_IMS_URL` - http://mitsims.in

**Optional:**
- `MONGODB_URI` - Database URL (or leave blank for mock mode)
- `ADMIN_TELEGRAM_BOT_TOKEN` - Admin bot token
- `ADMIN_TELEGRAM_CHAT_IDS` - Admin chat IDs

**Already set by render.yaml:**
- `NODE_ENV=production`
- `PUPPETEER_CACHE_DIR=/opt/render/.cache/puppeteer`
- `HEADLESS_MODE=true`

---

**Need more help?** See `CHROME_FIX_GUIDE.md` for detailed troubleshooting.
