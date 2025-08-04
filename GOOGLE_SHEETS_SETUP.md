# Google Sheets Integration Setup Guide

## Issues Fixed

The following issues have been identified and fixed:

1. **❌ Missing .env file** - Environment variables were not configured
2. **❌ Incorrect sheet name** - Code was referencing "Sheet1" instead of "LOADING AND RETURNS"
3. **❌ Range parsing errors** - Google Sheets API was rejecting the range format

## Setup Instructions

### 1. Create Google Cloud Project and Enable Google Sheets API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sheets API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sheets API"
   - Click "Enable"

### 2. Create Service Account

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Fill in the service account details
4. Click "Create and Continue"
5. Skip the optional steps and click "Done"

### 3. Generate Service Account Key

1. Click on your newly created service account
2. Go to the "Keys" tab
3. Click "Add Key" > "Create New Key"
4. Choose "JSON" format
5. Download the JSON file

### 4. Share Google Sheets with Service Account

1. Open your Google Sheets document
2. Click "Share" in the top right
3. Add your service account email (found in the JSON file) with "Editor" permissions
4. Copy the Spreadsheet ID from the URL (the long string between /d/ and /edit)

### 5. Create .env File

Create a `.env` file in the project root with the following content:

```env
# Google Sheets API Configuration
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id_here
GOOGLE_SHEETS_CLIENT_EMAIL=your_service_account_email@your-project.iam.gserviceaccount.com
GOOGLE_SHEETS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key content here\n-----END PRIVATE KEY-----\n"
```

**Important Notes:**
- Replace `your_spreadsheet_id_here` with your actual spreadsheet ID
- Replace `your_service_account_email@your-project.iam.gserviceaccount.com` with the email from your JSON file
- Replace the private key with the actual private key from your JSON file
- Make sure to include the quotes around the private key
- The `\n` characters represent actual newlines in the private key

### 6. Verify Setup

Run the diagnostic script to verify everything is working:

```bash
dart diagnose_sheets.dart
```

This will check:
- ✅ Environment variables are loaded
- ✅ Google Sheets API connection
- ✅ Sheet names are accessible
- ✅ Required sheet "LOADING AND RETURNS" exists
- ✅ Data can be read from the sheet

## Sheet Structure Requirements

Your Google Sheets document should have a sheet named **"LOADING AND RETURNS"** with the following columns:

- Date
- Driver Name
- Vehicle Number
- Product quantities (B-Steady 24x200ml, B-Steady Pieces, etc.)
- Notes

## Troubleshooting

### Common Issues:

1. **"Missing environment variables"**
   - Check that your `.env` file exists in the project root
   - Verify all three variables are set correctly

2. **"Sheet not found"**
   - Ensure your sheet is named exactly "LOADING AND RETURNS"
   - Check that the service account has access to the spreadsheet

3. **"Authentication failed"**
   - Verify the service account email and private key are correct
   - Make sure the service account has been shared with the spreadsheet

4. **"Range parsing error"**
   - This has been fixed by updating the sheet name references

### Running Tests

To test the Google Sheets integration:

```bash
flutter test test/google_sheets_service_test.dart
```

## Files Modified

The following files have been updated to fix the issues:

- `lib/screens/loading_returns_screen.dart` - Updated sheet name references
- `lib/services/google_sheets_service.dart` - Added validation and better error messages
- `test/google_sheets_service_test.dart` - Updated test cases
- `diagnose_sheets.dart` - New diagnostic script
- `env_template.txt` - Environment variables template 