const mongoose = require('mongoose');
require('dotenv').config();

const connectDB = async () => {
  try {
    // Check if MONGODB_URI is provided and valid
    const mongoUri = process.env.MONGODB_URI;
    const isLocalhost = mongoUri && (mongoUri.includes('localhost') || mongoUri.includes('127.0.0.1'));
    
    if (!mongoUri || (process.env.NODE_ENV === 'production' && isLocalhost)) {
      console.warn('\n⚠️  MongoDB URI is not configured for production.');
      
      // In production environment, enable mock mode automatically if no DB URI is provided
      if (process.env.NODE_ENV === 'production') {
        console.warn('   Production environment detected without valid MONGODB_URI.');
        console.warn('   Automatically enabling MOCK MODE for deployment.');
        console.warn('   The system will work with sample data.\n');
        process.env.USE_MOCK_DATA = 'true';
        return null;
      } else {
        console.error('   Please set MONGODB_URI environment variable or enable mock mode.');
        throw new Error('MONGODB_URI not configured');
      }
    }

    // Remove deprecated options
    const conn = await mongoose.connect(mongoUri);

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
    
    // Check if mock mode is explicitly enabled OR if we're in production without a DB URI
    const mockModeExplicit = process.env.USE_MOCK_DATA === 'true';
    const productionWithoutDB = process.env.NODE_ENV === 'production' && !process.env.MONGODB_URI;
    const shouldUseMockMode = mockModeExplicit || productionWithoutDB;
    
    if (shouldUseMockMode) {
      // Automatically enable mock mode
      process.env.USE_MOCK_DATA = 'true';
      
      console.warn('\n⚠️  MongoDB connection failed.');
      console.warn('   MOCK MODE is enabled - the system will work with sample data.');
      console.warn('   Database features (save/retrieve records) will not work.');
      
      if (process.env.NODE_ENV === 'production') {
        if (!process.env.MONGODB_URI) {
          console.warn('   No MONGODB_URI provided - running with mock data.\n');
        } else {
          console.warn('   Production environment - check your MongoDB connection string.\n');
        }
      } else {
        console.warn('   To use real database, configure MONGODB_URI in .env file.\n');
      }
      
      return null; // Return null instead of exiting
    }
    
    // Only show error and exit in development without mock mode
    console.error('\n⚠️  MongoDB is not available. Please either:');
    console.error('   1. Install and start MongoDB locally');
    console.error('   2. Use MongoDB Atlas (free): https://www.mongodb.com/cloud/atlas');
    console.error('   3. Update MONGODB_URI in .env file');
    console.error('   4. Enable mock mode: SET USE_MOCK_DATA=true in .env\n');
    process.exit(1);
  }
};

module.exports = connectDB;
