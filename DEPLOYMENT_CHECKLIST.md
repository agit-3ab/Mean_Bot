# Render Deployment Checklist for Mean Bot

## Pre-Deployment Checklist

### 1. Repository Setup
- [ ] Code is pushed to GitHub repository
- [ ] `render.yaml` file is present
- [ ] `build.sh` file is present and executable
- [ ] `package.json` includes build script
- [ ] `.gitignore` excludes sensitive files

### 2. External Services Setup
- [ ] MongoDB Atlas cluster created
- [ ] Database user created with read/write permissions
- [ ] Network access configured (allow 0.0.0.0/0 for Render)
- [ ] Connection string obtained
- [ ] Main Telegram bot created via @BotFather
- [ ] Admin Telegram bot created via @BotFather
- [ ] Admin chat IDs obtained via @userinfobot

### 3. Environment Variables Ready
- [ ] `MONGODB_URI` - MongoDB Atlas connection string
- [ ] `ENCRYPTION_KEY` - 32-character secure key
- [ ] `TELEGRAM_BOT_TOKEN` - Main bot token
- [ ] `ADMIN_TELEGRAM_BOT_TOKEN` - Admin bot token
- [ ] `ADMIN_TELEGRAM_CHAT_IDS` - Comma-separated chat IDs
- [ ] `ATTENDANCE_CHECK_TIME` - Time in HH:MM format
- [ ] `MITS_IMS_URL` - Target university URL

## Deployment Steps

### 1. Create Render Service
- [ ] Go to render.com and sign in
- [ ] Click "New" → "Blueprint" (if using render.yaml)
- [ ] Or click "New" → "Web Service" (for manual setup)
- [ ] Connect GitHub repository

### 2. Configure Service
- [ ] Service name: `mean-bot`
- [ ] Environment: Node
- [ ] Build command: `chmod +x build.sh && ./build.sh`
- [ ] Start command: `npm start`
- [ ] Plan: Starter (free tier)

### 3. Set Environment Variables
- [ ] Add all required environment variables in Render dashboard
- [ ] Verify no typos in variable names
- [ ] Ensure special characters are properly escaped

### 4. Deploy and Test
- [ ] Trigger deployment
- [ ] Monitor build logs for errors
- [ ] Check service logs after deployment
- [ ] Test main Telegram bot
- [ ] Test admin Telegram bot
- [ ] Verify database connection

## Post-Deployment Verification

### 1. Service Health
- [ ] Service shows as "Live" in Render dashboard
- [ ] No errors in service logs
- [ ] Memory usage is reasonable
- [ ] CPU usage is reasonable

### 2. Bot Functionality
- [ ] Main bot responds to messages
- [ ] Admin bot responds to admin commands
- [ ] Database operations work correctly
- [ ] Scheduled tasks are running
- [ ] Error notifications are sent to admins

### 3. Monitoring
- [ ] Set up log monitoring
- [ ] Test bot restart scenarios
- [ ] Verify backup procedures
- [ ] Document any custom configurations

## Troubleshooting Common Issues

### Build Failures
- [ ] Check Chrome installation in build logs
- [ ] Verify all dependencies are in package.json
- [ ] Ensure build.sh has proper permissions

### Runtime Errors
- [ ] Verify all environment variables are set
- [ ] Check MongoDB connection string format
- [ ] Validate Telegram bot tokens
- [ ] Ensure admin chat IDs are correct

### Performance Issues
- [ ] Monitor memory usage (Render free tier limit: 512MB)
- [ ] Check for memory leaks in Puppeteer
- [ ] Optimize browser resource usage
- [ ] Consider upgrading to paid plan if needed

## Notes
- Free tier sleeps after 15 minutes of inactivity
- Consider paid plan for production use
- Keep sensitive data secure
- Regularly update dependencies