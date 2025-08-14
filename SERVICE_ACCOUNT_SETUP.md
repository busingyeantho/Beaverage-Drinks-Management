# Google Cloud Service Account Setup Guide

## Why You Need This

Your app is currently using your personal Gmail (`busingyeanthony77@gmail.com`) which **will not work** for Google Sheets API authentication. You need a **Service Account** from Google Cloud Console.

## Step-by-Step Setup

### Step 1: Go to Google Cloud Console
1. Visit [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Create a new project or select an existing one

### Step 2: Enable Google Sheets API
1. In the left sidebar, go to "APIs & Services" > "Library"
2. Search for "Google Sheets API"
3. Click on it and click "Enable"

### Step 3: Create a Service Account
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Fill in the details:
   - **Service account name**: `john-pombe-sheets` (or any name you prefer)
   - **Service account ID**: Will auto-generate
   - **Description**: `Service account for John Pombe app Google Sheets access`
4. Click "Create and Continue"
5. Skip the optional steps (click "Continue" and "Done")

### Step 4: Generate the Private Key
1. Click on your newly created service account
2. Go to the "Keys" tab
3. Click "Add Key" > "Create new key"
4. Choose "JSON" format
5. Click "Create"
6. The JSON file will download automatically

### Step 5: Extract the Credentials
Open the downloaded JSON file. It will look like this:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDSnywxRNuAMI7s\n...\n-----END PRIVATE KEY-----",
  "client_email": "john-pombe-sheets@your-project-id.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/john-pombe-sheets%40your-project-id.iam.gserviceaccount.com"
}
```

**Copy these values:**
- `client_email` (looks like `something@project-id.iam.gserviceaccount.com`)
- `private_key` (the entire key including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

### Step 6: Update Your Configuration
Update `web/config.js` with the real values:

```javascript
window.googleSheetsConfig = {
  spreadsheetId: '1WT1CGVxaHp2sVtka5ynU8SEef2m1GXJKNjOOEdus3Bc',
  clientEmail: 'john-pombe-sheets@your-project-id.iam.gserviceaccount.com', // Use the real client_email
  privateKey: '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDSnywxRNuAMI7s\n...\n-----END PRIVATE KEY-----' // Use the real private_key
};
```

### Step 7: Share Your Google Sheet
1. Open your Google Sheet: [https://docs.google.com/spreadsheets/d/1WT1CGVxaHp2sVtka5ynU8SEef2m1GXJKNjOOEdus3Bc](https://docs.google.com/spreadsheets/d/1WT1CGVxaHp2sVtka5ynU8SEef2m1GXJKNjOOEdus3Bc)
2. Click "Share" (top right)
3. Add your service account email (the `client_email` from the JSON)
4. Give it "Editor" permissions
5. Click "Send" (no need to send an email, just click it)

### Step 8: Test Locally
1. Update your `web/config.js` with the real credentials
2. Run `flutter run -d chrome`
3. Check if the data loads without errors

### Step 9: Deploy
1. Build: `flutter build web`
2. Deploy: `firebase deploy --only hosting`

## Common Issues & Solutions

### "Invalid grant: account not found"
- **Cause**: Using personal Gmail instead of service account
- **Solution**: Use the service account email from the JSON file

### "Access denied" or "Permission denied"
- **Cause**: Service account doesn't have access to the sheet
- **Solution**: Share the Google Sheet with the service account email

### "API not enabled"
- **Cause**: Google Sheets API not enabled in your project
- **Solution**: Enable Google Sheets API in Google Cloud Console

## Security Note
⚠️ **Important**: The credentials will be visible in your website's source code. For production apps, consider using Firebase Functions for server-side API calls.

## Need Help?
If you encounter issues:
1. Check the browser console for error messages
2. Verify the service account email is correct
3. Ensure the Google Sheet is shared with the service account
4. Confirm Google Sheets API is enabled in your project
