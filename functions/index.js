const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { getSheetNames, getSheetData } = require('./services/googleSheetsService');
// Default to Firebase Hosting domains if no CORS origins specified
const defaultOrigins = [
  'https://johnpomb-b85d0.web.app',
  'https://johnpomb-b85d0.firebaseapp.com',
  'http://localhost:5000', // For local development
];
const allowedOrigins = (process.env.ALLOWED_CORS_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);
const finalOrigins = allowedOrigins.length > 0 ? allowedOrigins : defaultOrigins;
const requireAuth = (process.env.REQUIRE_AUTH || '').toLowerCase() === 'true';
const cors = require('cors')({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true); // Allow non-browser clients
    if (finalOrigins.includes(origin)) {
      return callback(null, true);
    }
    console.warn(`CORS blocked origin: ${origin}`);
    callback(new Error(`Origin ${origin} not allowed by CORS policy`));
  },
});

// Initialize Admin SDK once
try { admin.initializeApp(); } catch (_) {}

// Set global options for all functions
functions.setGlobalOptions({
  maxInstances: 10,
  memory: '256MB',
  timeoutSeconds: 60,
});

// Verify Firebase ID token from Authorization: Bearer <token>
async function verifyAuth(req) {
  const authHeader = req.headers.authorization || '';
  const match = authHeader.match(/^Bearer (.*)$/);
  if (!match) {
    throw Object.assign(new Error('Unauthorized'), { status: 401 });
  }
  const idToken = match[1];
  const decoded = await admin.auth().verifyIdToken(idToken);
  return decoded;
}

// Helper function to handle CORS, auth and errors
const handleRequest = (handler) => (req, res) => {
  return cors(req, res, async () => {
    try {
      // Enforce auth if enabled
      if (requireAuth) {
        const user = await verifyAuth(req);
        req.user = user;
      }
      const result = await handler(req, res);
      return res.status(200).json(result);
    } catch (error) {
      console.error('Error:', error);
      const status = error.status || 500;
      return res.status(status).json({
        success: false,
        error: error.message || 'An error occurred',
        stack: process.env.NODE_ENV === 'development' ? error.stack : undefined,
      });
    }
  });
};

// Get sheet names
const getSheetNamesHandler = async (req) => {
  const { spreadsheetId } = req.query;
  
  if (!spreadsheetId) {
    throw new Error('Spreadsheet ID is required');
  }
  
  const names = await getSheetNames(spreadsheetId);
  return { success: true, data: names };
};

// Get sheet data
const getSheetDataHandler = async (req) => {
  const { spreadsheetId, range } = req.query;
  
  if (!spreadsheetId || !range) {
    throw new Error('Spreadsheet ID and range are required');
  }
  
  const data = await getSheetData(spreadsheetId, range);
  return { success: true, data };
};

// Export the functions
exports.getSheetNames = functions.https.onRequest(handleRequest(getSheetNamesHandler));
exports.getSheetData = functions.https.onRequest(handleRequest(getSheetDataHandler));
