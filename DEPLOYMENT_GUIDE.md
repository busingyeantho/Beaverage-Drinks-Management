# Deployment Guide for Firebase Hosting

## Problem
When deploying your Flutter web app to Firebase hosting, the Google Sheets API credentials from your `.env` file are not available, causing the error:
```
Failed to load data: GoogleSheetsException: Failed to get sheet names
Error: GoogleSheetsException: Failed to initialize Google Sheets API
Error: Failed to obtain access credentials. Error: invalid_grant Invalid grant: account not found Status code: 400
```

## Solution
The credentials need to be configured in the web configuration files since environment variables are not available in the browser.

## Step-by-Step Setup

### 1. Update Configuration Files

#### Update `web/config.js`
Replace the placeholder values with your actual Google Sheets API credentials:

```javascript
window.googleSheetsConfig = {
  // Your Google Sheets Spreadsheet ID (found in the URL)
  spreadsheetId: '1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms',
  
  // Service Account Email (from your Google Cloud Console)
  clientEmail: 'your-service-account@your-project.iam.gserviceaccount.com',
  
  // Private Key (from your service account JSON file)
  privateKey: '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----'
};
```

#### Update `web/index.html`
Replace the Firebase configuration values with your actual Firebase project values:

```javascript
window.flutterConfiguration = {
  'FIREBASE_API_KEY': 'AIzaSyC-your-actual-api-key',
  'FIREBASE_AUTH_DOMAIN': 'your-project.firebaseapp.com',
  'FIREBASE_PROJECT_ID': 'your-project-id',
  'FIREBASE_STORAGE_BUCKET': 'your-project.appspot.com',
  'FIREBASE_MESSAGING_SENDER_ID': '1234567890',
  'FIREBASE_APP_ID': '1:1234567890:web:abcdef123456'
};
```

### 2. Get Your Google Sheets API Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to "APIs & Services" > "Credentials"
4. Find your service account or create a new one
5. Download the JSON key file
6. Extract the required values:
   - `client_email`
   - `private_key`
   - `spreadsheet_id` (from your Google Sheets URL)

### 3. Build and Deploy

```bash
# Build the web app
flutter build web

# Deploy to Firebase
firebase deploy --only hosting
```

### 4. Verify Configuration

After deployment, check the browser console to ensure:
- No configuration errors
- Google Sheets API credentials are loaded
- The app can connect to your sheets

## Security Notes

⚠️ **IMPORTANT**: The credentials in `web/config.js` will be visible to anyone who views your website's source code. This is a limitation of client-side web applications.

### Alternative Solutions for Production

1. **Use Firebase Functions**: Move the Google Sheets API calls to Firebase Functions (server-side)
2. **Use a Backend Service**: Create a separate backend API to handle Google Sheets operations
3. **Use Firebase Extensions**: Consider using Firebase Extensions for Google Sheets integration

## Troubleshooting

### Common Issues

1. **Credentials not loading**: Check browser console for JavaScript errors
2. **Invalid grant error**: Verify your service account has access to the Google Sheets API
3. **Spreadsheet not found**: Ensure the spreadsheet ID is correct and the service account has access

### Debug Steps

1. Check browser console for configuration values
2. Verify `window.flutterConfiguration` contains your credentials
3. Test Google Sheets API access in Google Cloud Console
4. Check Firebase hosting logs: `firebase hosting:log`

## Testing Locally

Before deploying, test your configuration locally:

```bash
flutter run -d chrome
```

Check the browser console to ensure credentials are loaded correctly.

## Next Steps

After successful deployment:
1. Test all functionality (Loadings, Returns, Sales)
2. Monitor for any API quota issues
3. Consider implementing rate limiting
4. Set up monitoring and alerts
