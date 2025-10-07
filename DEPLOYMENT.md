# Mean Bot - Render Deployment Guide

This guide will help you deploy the Mean Bot (Attendance Automation System) to Render.

## Prerequisites

1. A [Render](https://render.com) account
2. A GitHub account with your Mean Bot repository
3. MongoDB Atlas database (recommended for production)
4. Telegram Bot tokens from BotFather

## Step 1: Prepare Your Repository

1. Ensure your code is pushed to a GitHub repository
2. The following files should be present in your repository:
   - `render.yaml` (deployment configuration)
   - `build.sh` (build script for Puppeteer dependencies)
   - `package.json` (with updated scripts)

## Step 2: Set Up MongoDB Atlas (Recommended)

1. Go to [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Create a free cluster
3. Create a database user
4. Get your connection string (it should look like: `mongodb+srv://username:password@cluster.mongodb.net/attendance_system`)

## Step 3: Create Telegram Bots

1. Message [@BotFather](https://t.me/botfather) on Telegram
2. Create two bots:
   - Main bot: `/newbot` → Follow instructions
   - Admin bot: `/newbot` → Follow instructions
3. Save both bot tokens
4. Get your Telegram chat ID by messaging [@userinfobot](https://t.me/userinfobot)

## Step 4: Deploy to Render

### Method 1: Using render.yaml (Recommended)

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New" → "Blueprint"
3. Connect your GitHub repository
4. Render will automatically detect the `render.yaml` file
5. Click "Apply"

### Method 2: Manual Setup

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New" → "Web Service"
3. Connect your GitHub repository
4. Configure the service:
   - **Name**: `mean-bot` (or your preferred name)
   - **Environment**: `Node`
   - **Build Command**: `./build.sh`
   - **Start Command**: `npm start`
   - **Plan**: `Starter` (free tier)

## Step 5: Configure Environment Variables

In your Render service settings, add these environment variables:

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment | `production` |
| `MONGODB_URI` | MongoDB connection string | `mongodb+srv://user:pass@cluster.mongodb.net/attendance_system` |
| `ENCRYPTION_KEY` | 32-character encryption key | `your_32_character_encryption_key_here` |
| `TELEGRAM_BOT_TOKEN` | Main Telegram bot token | `123456789:ABCdefGHIjklMNOpqrsTUVwxyz` |
| `ADMIN_TELEGRAM_BOT_TOKEN` | Admin Telegram bot token | `987654321:ZYXwvuTSRqponMLKjihgFEDcba` |
| `ADMIN_TELEGRAM_CHAT_IDS` | Admin chat IDs (comma-separated) | `123456789,987654321` |
| `ATTENDANCE_CHECK_TIME` | Daily check time (24h format) | `08:00` |
| `MITS_IMS_URL` | MITS IMS URL | `http://mitsims.in` |

### Puppeteer Configuration (Already set in render.yaml)

| Variable | Value | Description |
|----------|-------|-------------|
| `HEADLESS_MODE` | `true` | Run browser in headless mode |
| `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD` | `true` | Skip Chromium download during npm install |
| `PUPPETEER_EXECUTABLE_PATH` | `/usr/bin/google-chrome-stable` | Use system Chrome |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USE_MOCK_DATA` | `false` | Use mock data for testing |

## Step 6: Deploy and Monitor

1. After configuring environment variables, trigger a new deployment
2. Monitor the deploy logs for any errors
3. Once deployed, check the service logs to ensure the bot is running
4. Test the Telegram bot by sending a message

## Troubleshooting

### Common Issues

1. **Puppeteer fails to start**
   - Ensure `PUPPETEER_EXECUTABLE_PATH` is set correctly
   - Check that `build.sh` installed Chrome properly

2. **Database connection fails**
   - Verify your `MONGODB_URI` is correct
   - Ensure your MongoDB Atlas cluster allows connections from anywhere (0.0.0.0/0)

3. **Telegram bot not responding**
   - Check that bot tokens are correct
   - Ensure chat IDs are properly formatted
   - Verify the bots are not blocked

4. **Build fails**
   - Check the build logs in Render dashboard
   - Ensure all dependencies are in `package.json`

### Viewing Logs

1. Go to your Render service dashboard
2. Click on "Logs" tab
3. Monitor real-time logs for errors or issues

## Important Notes

- The free tier on Render may have limitations (sleep after 15 minutes of inactivity)
- Consider upgrading to a paid plan for production use
- MongoDB Atlas free tier has storage limitations
- Keep your bot tokens and encryption keys secure

## Support

If you encounter issues:

1. Check the Render service logs
2. Review the GitHub repository for updates
3. Ensure all environment variables are correctly set

## Security Best Practices

1. Never commit `.env` files to your repository
2. Use strong, unique encryption keys
3. Regularly rotate your bot tokens
4. Limit admin chat IDs to trusted users only
5. Monitor your application logs regularly