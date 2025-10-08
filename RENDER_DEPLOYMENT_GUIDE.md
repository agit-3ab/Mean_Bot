# Render Deployment Guide for Mean Bot

## Quick Fix for Current Deployment Issue

Your deployment is failing because MongoDB is not available. The application has been updated to handle this gracefully by automatically enabling mock mode in production when no database is available.

### Immediate Solution

**Option 1: Enable Mock Mode (Recommended for testing)**
- In your Render dashboard, ensure the environment variable `USE_MOCK_DATA` is set to `true`
- This will allow the application to run without a database using sample data

**Option 2: Set up MongoDB Atlas (Recommended for production)**
1. Create a free MongoDB Atlas account at https://www.mongodb.com/cloud/atlas
2. Create a new cluster
3. Get your connection string
4. Set the `MONGODB_URI` environment variable in Render dashboard
5. Set `USE_MOCK_DATA` to `false`

## Environment Variables Setup

### Required Environment Variables (set in Render Dashboard)

1. **TELEGRAM_BOT_TOKEN** (Required)
   - Get from BotFather on Telegram
   - Example: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`

2. **ADMIN_TELEGRAM_BOT_TOKEN** (Required)
   - Second bot token from BotFather for admin functions
   - Example: `987654321:ZYXwvuTSRqponMLKjihGFEdcba`

3. **ADMIN_TELEGRAM_CHAT_IDS** (Required)
   - Comma-separated list of admin chat IDs
   - Example: `123456789,987654321`

4. **ENCRYPTION_KEY** (Required)
   - 32-character key for encrypting student passwords
   - Example: `abcdefghijklmnopqrstuvwxyz123456`

### Optional Environment Variables

5. **MONGODB_URI** (Optional - if not provided, mock mode will be enabled)
   - MongoDB Atlas connection string
   - Example: `mongodb+srv://username:password@cluster.mongodb.net/attendance_system`

6. **ATTENDANCE_CHECK_TIME** (Optional, defaults to 08:00)
   - Time for daily attendance checks
   - Example: `08:00`

7. **MITS_IMS_URL** (Optional)
   - URL of the MITS IMS system
   - Example: `http://mitsims.in`

## Deployment Options

### Option 1: Quick Deploy with Mock Mode (No Database)
1. Use `render-minimal.yaml` for deployment
2. Set only the required environment variables above
3. The app will automatically run in mock mode

### Option 2: Full Production Deploy with Database
1. Set up MongoDB Atlas
2. Use `render.yaml` or `render-simple.yaml`
3. Set all environment variables including `MONGODB_URI`
4. Set `USE_MOCK_DATA=false`

## Deployment Steps

1. **Fork/Clone the repository**
2. **Connect to Render**
   - Go to Render dashboard
   - Click "New +" → "Web Service"
   - Connect your GitHub repository

3. **Configure Service**
   - Runtime: Node
   - Build Command: `npm ci --only=production`
   - Start Command: `npm start`

4. **Set Environment Variables**
   - Go to Environment tab
   - Add the required variables listed above

5. **Deploy**
   - Click "Create Web Service"
   - Monitor deployment logs

## Troubleshooting

### MongoDB Connection Issues
- **Error**: `connect ECONNREFUSED ::1:27017`
- **Solution**: Set `USE_MOCK_DATA=true` or provide valid `MONGODB_URI`

### Puppeteer Issues
- **Error**: Chrome not found
- **Solution**: Use `render-simple.yaml` which uses system Chrome

### Bot Token Issues
- **Error**: Bot not responding
- **Solution**: Verify bot tokens are correct and bots are not used elsewhere

## Architecture Notes

- **Mock Mode**: When enabled, the system works with sample data
- **Database Mode**: Full functionality with data persistence
- **Graceful Fallback**: Production automatically enables mock mode if no DB is available
- **Health Monitoring**: System includes heartbeat and error reporting

## Support

If you encounter issues:
1. Check the deployment logs in Render dashboard
2. Verify all required environment variables are set
3. Ensure bot tokens are valid and unique
4. Consider starting with mock mode for testing

## Security Notes

- Never commit real tokens or keys to the repository
- Use strong encryption keys (32 characters)
- Regularly rotate sensitive credentials
- Use MongoDB Atlas IP whitelist for security