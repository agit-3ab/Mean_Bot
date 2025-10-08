const mongoose = require('mongoose');
require('dotenv').config();

const connectDB = async () => {
  try {
    // Check if MONGODB_URI is provided
    if (!process.env.MONGODB_URI) {
      console.warn('\n⚠️  MONGODB_URI environment variable is not set.');
      
      // In production environment, enable mock mode automatically if no DB URI is provided
      if (process.env.NODE_ENV === 'production') {
        console.warn('   Production environment detected without MONGODB_URI.');
        console.warn('   Automatically enabling MOCK MODE for deployment.');
        process.env.USE_MOCK_DATA = 'true';
        return null;
      } else {
        console.error('   Please set MONGODB_URI environment variable or enable mock mode.');
        throw new Error('MONGODB_URI not configured');
      }
    }

    // Remove deprecated options
    const conn = await mongoose.connect(process.env.MONGODB_URI);

    console.log(`MongoDB Connected: ${conn.connection.host}`);
    
    // Handle connection errors
    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('MongoDB disconnected');
    });

    // Graceful shutdown
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      console.log('MongoDB connection closed through app termination');
      process.exit(0);
    });

    return conn;
  } catch (error) {
    console.error('Error connecting to MongoDB:', error.message);
    
    // Check if mock mode is enabled or should be enabled
    if (process.env.USE_MOCK_DATA === 'true' || process.env.NODE_ENV === 'production') {
      console.warn('\n⚠️  MongoDB is not available, but MOCK MODE is enabled.');
      console.warn('   The system will work with sample data.');
      console.warn('   Database features (save/retrieve records) will not work.\n');
      
      // Ensure mock mode is enabled
      process.env.USE_MOCK_DATA = 'true';
      return null; // Return null instead of exiting
    } else {
      console.error('\n⚠️  MongoDB is not available. Please either:');
      console.error('   1. Install and start MongoDB locally');
      console.error('   2. Use MongoDB Atlas (free): https://www.mongodb.com/cloud/atlas');
      console.error('   3. Update MONGODB_URI in .env file');
      console.error('   4. Enable mock mode: SET USE_MOCK_DATA=true in .env\n');
      process.exit(1);
    }
  }
};

module.exports = connectDB;
