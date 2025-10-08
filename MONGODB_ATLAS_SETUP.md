# MongoDB Atlas Setup Guide for Render Deployment

Since you want to use a real database instead of mock mode, follow these steps to set up MongoDB Atlas (free tier) and connect it to your Render deployment.

## Step 1: Create MongoDB Atlas Account

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Click "Try Free" or "Sign Up"
3. Create an account (you can use Google/GitHub sign-in)

## Step 2: Create a Free Cluster

1. After signing in, click "Build a Database"
2. Choose **M0 (FREE)** tier
3. Select a cloud provider and region (choose one close to your Render region)
   - For Render Oregon, choose **AWS - us-west-2** or similar
4. Name your cluster (e.g., "mean-bot-cluster")
5. Click "Create Cluster" (takes 3-5 minutes)

## Step 3: Create Database User

1. On the left sidebar, click **Database Access**
2. Click **Add New Database User**
3. Choose **Password** authentication
4. Username: `meanbot` (or any name you prefer)
5. Click **Autogenerate Secure Password** (SAVE THIS PASSWORD!)
6. Built-in Role: Select **Read and write to any database**
7. Click **Add User**

## Step 4: Configure Network Access

1. On the left sidebar, click **Network Access**
2. Click **Add IP Address**
3. Click **Allow Access from Anywhere** (0.0.0.0/0)
   - This is needed for Render to connect
   - Click **Confirm**

## Step 5: Get Connection String

1. Go back to **Database** (left sidebar)
2. Click **Connect** on your cluster
3. Choose **Connect your application**
4. Driver: **Node.js**
5. Copy the connection string (looks like this):
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

6. Replace `<username>` with your database username (e.g., `meanbot`)
7. Replace `<password>` with the password you saved
8. Add your database name before the `?`:
   ```
   mongodb+srv://meanbot:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/attendance_system?retryWrites=true&w=majority
   ```

## Step 6: Configure Render Environment Variables

1. Go to your Render dashboard
2. Select your **mean-bot** service
3. Go to **Environment** tab
4. Add/Update these environment variables:

   **Required:**
   ```
   MONGODB_URI=mongodb+srv://meanbot:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/attendance_system?retryWrites=true&w=majority
   NODE_ENV=production
   USE_MOCK_DATA=false
   ENCRYPTION_KEY=your_32_character_encryption_key_here_change_this
   TELEGRAM_BOT_TOKEN=your_telegram_bot_token_from_botfather
   ADMIN_TELEGRAM_BOT_TOKEN=your_admin_telegram_bot_token
   ADMIN_TELEGRAM_CHAT_IDS=your_chat_id
   ATTENDANCE_CHECK_TIME=08:00
   MITS_IMS_URL=http://mitsims.in
   ```

   **Optional (Puppeteer settings):**
   ```
   HEADLESS_MODE=true
   PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
   ```

5. Click **Save Changes**

## Step 7: Deploy

1. Commit and push your code changes:
   ```bash
   git add .
   git commit -m "Configure for MongoDB Atlas production deployment"
   git push origin main
   ```

2. Render will automatically redeploy

## Step 8: Verify Deployment

Check Render logs for successful connection:

```
MongoDB Connected: cluster0-shard-00-00.xxxxx.mongodb.net
============================================================
🚀 Attendance Telegram Bot Service Started
============================================================
Environment: production
Database: mongodb+srv://meanbot:***@cluster0.xxxxx.mongodb.net/attendance_system
Mock Mode: Disabled
User Bot: ENABLED ✅
Admin Bot: ENABLED ✅
============================================================
```

## Troubleshooting

### Connection Issues

If you see `MongoServerError: bad auth`:
- Double-check username and password in connection string
- Make sure you're using the database user credentials, not your Atlas account credentials

If you see `connection timeout`:
- Verify Network Access allows 0.0.0.0/0
- Check that your cluster is running (not paused)

If you see `Authentication failed`:
- Make sure the password doesn't contain special characters that need URL encoding
- If password has special characters like `@`, `#`, `%`, use URL encoding:
  - `@` → `%40`
  - `#` → `%23`
  - `%` → `%25`

### Database User Issues

If authentication fails:
1. Go to Database Access in Atlas
2. Edit your user
3. Reset the password
4. Update the MONGODB_URI in Render

## Security Best Practices

✅ **Do:**
- Use a strong, unique password for database user
- Regularly rotate your database password
- Use environment variables for sensitive data
- Monitor your Atlas usage/logs

❌ **Don't:**
- Commit your MONGODB_URI to Git
- Share your database credentials publicly
- Use the same password for multiple services

## Cost Information

- **M0 Free Tier includes:**
  - 512 MB storage
  - Shared RAM
  - Shared vCPU
  - No credit card required
  - Sufficient for small to medium applications

- **Monitoring:**
  - Check Atlas dashboard for storage usage
  - Free tier never expires
  - Can upgrade to paid tier if needed

## Quick Reference

**MongoDB Atlas Dashboard:** https://cloud.mongodb.com

**Connection String Format:**
```
mongodb+srv://USERNAME:PASSWORD@CLUSTER.mongodb.net/DATABASE_NAME?retryWrites=true&w=majority
```

**Example (replace with your values):**
```
mongodb+srv://meanbot:MySecurePass123@mean-bot-cluster.abc123.mongodb.net/attendance_system?retryWrites=true&w=majority
```

## Next Steps After Setup

1. Test your Telegram bot
2. Add students via admin bot
3. Monitor database in Atlas dashboard
4. Set up backups if needed (available in paid tiers)

---

**Need Help?**
- MongoDB Atlas Docs: https://www.mongodb.com/docs/atlas/
- Atlas Support: Available in free tier
