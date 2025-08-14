const functions = require('firebase-functions');
const { getSheetNames, getSheetData } = require('./services/googleSheetsService');
const cors = require('cors')({ origin: true });

// Set global options for all functions
functions.setGlobalOptions({
  maxInstances: 10,
  memory: '256MB',
  timeoutSeconds: 60,
});

// Helper function to handle CORS and errors
const handleRequest = (handler) => (req, res) => {
  return cors(req, res, async () => {
    try {
      const result = await handler(req, res);
      return result;
    } catch (error) {
      console.error('Error:', error);
      return res.status(500).json({
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
