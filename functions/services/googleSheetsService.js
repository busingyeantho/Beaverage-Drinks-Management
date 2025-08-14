const { google } = require('googleapis');
const functions = require('firebase-functions');

// Initialize the Google Sheets API
const sheets = google.sheets('v4');

// Get service account credentials from Firebase config
const config = functions.config();

const credentials = {
  "type": "service_account",
  "project_id": config.google?.sheets?.project_id || process.env.GOOGLE_SHEETS_PROJECT_ID,
  "private_key_id": config.google?.sheets?.private_key_id || process.env.GOOGLE_SHEETS_PRIVATE_KEY_ID,
  "private_key": (config.google?.sheets?.private_key || process.env.GOOGLE_SHEETS_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
  "client_email": config.google?.sheets?.client_email || process.env.GOOGLE_SHEETS_CLIENT_EMAIL,
  "client_id": config.google?.sheets?.client_id || process.env.GOOGLE_SHEETS_CLIENT_ID,
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
};

// Create a JWT client for authentication
const auth = new google.auth.JWT(
  credentials.client_email,
  null,
  credentials.private_key,
  ['https://www.googleapis.com/auth/spreadsheets']
);

// Get sheet names from a spreadsheet
async function getSheetNames(spreadsheetId) {
  try {
    const response = await sheets.spreadsheets.get({
      auth,
      spreadsheetId,
      fields: 'sheets.properties.title',
    });

    return response.data.sheets.map(sheet => sheet.properties.title);
  } catch (error) {
    console.error('Error getting sheet names:', error);
    throw new Error(`Failed to get sheet names: ${error.message}`);
  }
}

// Get data from a specific sheet
async function getSheetData(spreadsheetId, range) {
  try {
    const response = await sheets.spreadsheets.values.get({
      auth,
      spreadsheetId,
      range,
    });

    return response.data.values || [];
  } catch (error) {
    console.error('Error getting sheet data:', error);
    throw new Error(`Failed to get sheet data: ${error.message}`);
  }
}

module.exports = {
  getSheetNames,
  getSheetData,
};
