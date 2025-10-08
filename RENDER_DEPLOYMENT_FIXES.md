# Render Deployment Troubleshooting Guide

## Fixed Issues

### 1. Package Lock File ✅
- `package-lock.json` is now present and up-to-date
- This ensures consistent dependency versions across deployments

### 2. Build Configuration ✅
- Updated `render.yaml` with proper Puppeteer environment variables
- Added essential Puppeteer arguments for headless browser operation in containerized environments
- Build command now uses `./build.sh` for more comprehensive setup

### 3. Simplified Build Script ✅
- Enhanced `build.sh` with better error handling and environment detection
- Added system dependency installation for Puppeteer (Chromium)
- Improved dependency verification process
- Added production-only npm install option

### 4. Alternative Configuration ✅
- Created `render-simple.yaml` as a fallback option that doesn't use build script
- This can be renamed to `render.yaml` if the build script approach fails

## Deployment Options

### Option 1: Use Enhanced Build Script (Recommended)
Use the current `render.yaml` which calls `./build.sh`

### Option 2: Use Simple Configuration
If Option 1 fails, rename `render-simple.yaml` to `render.yaml`:
```bash
mv render-simple.yaml render.yaml
```

## Environment Variables Required in Render Dashboard

Make sure to set these in your Render service environment variables:

### Required Variables
- `MONGODB_URI` - Your MongoDB connection string
- `ENCRYPTION_KEY` - 32 character encryption key for data security
- `TELEGRAM_BOT_TOKEN` - Bot token from BotFather
- `ADMIN_TELEGRAM_BOT_TOKEN` - Admin bot token from BotFather
- `ADMIN_TELEGRAM_CHAT_IDS` - Comma-separated admin chat IDs
- `ATTENDANCE_CHECK_TIME` - Time for attendance checks (e.g., "08:00")
- `MITS_IMS_URL` - URL of the IMS system (e.g., "http://mitsims.in")

### Optional Variables
- `USE_MOCK_DATA` - Set to "false" for production (defaults to false)

## Troubleshooting Common Issues

### Build Fails on Dependencies
1. Check if `package-lock.json` is committed
2. Verify Node.js version compatibility (>=16.0.0)
3. Try using the simple configuration option

### Puppeteer Issues
1. Environment variables are set correctly for headless operation
2. System dependencies should be installed by build script
3. Chrome executable path is set to Render's default location

### Memory Issues
1. Consider upgrading to a higher Render plan if needed
2. Monitor memory usage in Render dashboard
3. Optimize Puppeteer instances in the application code

## Deployment Steps

1. Commit all changes to your repository
2. Push to your main branch
3. In Render dashboard, ensure all environment variables are set
4. Trigger a new deployment
5. Monitor build logs for any issues
6. Check service logs once deployed

## Monitoring

- Check Render service logs for runtime issues
- Monitor Telegram bot connectivity
- Verify MongoDB connection
- Check scheduled task execution