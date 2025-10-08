# Real Database Deployment Guide

## Changes Made for Real Database Support

I've updated the configuration to support **real MongoDB** instead of mock mode:

### 1. Updated `render.yaml`
- Changed `USE_MOCK_DATA` from `true` to `false`
- This tells the app to use a real database

### 2. Improved `config/database.js`
- Better logic to detect when to use mock mode vs real database
- Only uses mock mode if:
  - `USE_MOCK_DATA=true` explicitly set, OR
  - In production with NO `MONGODB_URI` provided
- If you provide `MONGODB_URI`, it will use the real database

## What You Need to Do

### Step 1: Set Up MongoDB Atlas (Free)

Follow the complete guide in `MONGODB_ATLAS_SETUP.md` which includes:
1. Create free MongoDB Atlas account
2. Create a free cluster (M0 tier - no credit card needed)
3. Create database user with password
4. Whitelist all IPs (0.0.0.0/0) for Render access
5. Get your connection string

### Step 2: Configure Render Environment Variables

In your Render dashboard, set these environment variables:

**REQUIRED:**
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/attendance_system?retryWrites=true&w=majority
NODE_ENV=production
USE_MOCK_DATA=false
ENCRYPTION_KEY=your_32_character_encryption_key_here
TELEGRAM_BOT_TOKEN=your_bot_token
ADMIN_TELEGRAM_BOT_TOKEN=your_admin_bot_token
ADMIN_TELEGRAM_CHAT_IDS=your_chat_ids
ATTENDANCE_CHECK_TIME=08:00
MITS_IMS_URL=http://mitsims.in
```

**OPTIONAL:**
```
HEADLESS_MODE=true
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
```

### Step 3: Deploy

```bash
git add .
git commit -m "Configure for real MongoDB database deployment"
git push origin main
```

Render will automatically deploy with your real database!

## Expected Success Output

When properly configured, you should see in Render logs:

```
MongoDB Connected: cluster0-shard-00-00.xxxxx.mongodb.net
============================================================
🚀 Attendance Telegram Bot Service Started
============================================================
Environment: production
Database: mongodb+srv://***@cluster.mongodb.net/attendance_system
Mock Mode: Disabled
User Bot: ENABLED ✅
Admin Bot: ENABLED ✅
============================================================
✅ Scheduler initialized and started
```

## Troubleshooting

### If deployment fails with MongoDB errors:

1. **Check MONGODB_URI format:**
   ```
   mongodb+srv://USERNAME:PASSWORD@CLUSTER.mongodb.net/DATABASE_NAME?retryWrites=true&w=majority
   ```

2. **Verify in Render dashboard:**
   - Environment variable `MONGODB_URI` is set
   - Environment variable `USE_MOCK_DATA` is set to `false`
   - No typos in the connection string

3. **Check MongoDB Atlas:**
   - Cluster is running (not paused)
   - Network Access allows 0.0.0.0/0
   - Database user exists with correct password
   - Password doesn't have special characters (or they're URL-encoded)

4. **Common password encoding:**
   - If password has `@` → replace with `%40`
   - If password has `#` → replace with `%23`
   - If password has `%` → replace with `%25`

### If you see "Mock Mode Enabled" when you don't want it:

Check Render environment variables:
- Make sure `USE_MOCK_DATA=false` (not `true`)
- Make sure `MONGODB_URI` is set and not empty
- Redeploy after changing environment variables

## Database Features You'll Get

With real MongoDB, you'll have:
- ✅ Persistent student data storage
- ✅ Attendance history tracking
- ✅ Data survives restarts
- ✅ Multiple students support
- ✅ Historical attendance queries
- ✅ Real-time data updates

## Cost: $0 (Free Tier)

MongoDB Atlas M0 (Free) tier includes:
- 512 MB storage (plenty for this app)
- Shared infrastructure
- No credit card required
- Never expires
- Perfect for small to medium apps

## Files Reference

- `MONGODB_ATLAS_SETUP.md` - Step-by-step MongoDB Atlas setup
- `config/database.js` - Database connection logic
- `render.yaml` - Render deployment configuration

## Quick Checklist

- [ ] MongoDB Atlas account created
- [ ] Free cluster created (M0 tier)
- [ ] Database user created with password
- [ ] Network access configured (0.0.0.0/0)
- [ ] Connection string copied
- [ ] MONGODB_URI set in Render
- [ ] USE_MOCK_DATA=false in Render
- [ ] Other required env vars set in Render
- [ ] Code pushed to GitHub
- [ ] Deployment successful in Render
- [ ] Logs show "MongoDB Connected"

---

**Ready to deploy with real database!** 🚀
