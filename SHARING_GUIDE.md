# John Pombe - Project Sharing Guide

## 🚀 How to Share This Project

This guide explains how to share the John Pombe Alcoholic Drinks Management System with others.

## 📋 What Recipients Need to Do

### 1. **Clone/Copy the Project**
- Get the project files (all except the `.env` file)
- The `.env` file should NOT be shared (contains sensitive credentials)

### 2. **Set Up Google Cloud Project**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable Google Sheets API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sheets API"
   - Click "Enable"

### 3. **Create Service Account**
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Fill in details and create
4. Generate a JSON key file
5. Download the JSON file

### 4. **Create Google Sheets Document**
1. Create a new Google Sheets document
2. Create 3 sheets with these exact names:
   - **"LOADINGS"** - for morning loading data
   - **"RETURNS"** - for evening return data
   - **"SALES"** - for calculated sales (optional, can be auto-generated)

### 5. **Share Google Sheets**
1. Click "Share" in your Google Sheets
2. Add your service account email (from the JSON file) with "Editor" permissions
3. Copy the Spreadsheet ID from the URL

### 6. **Create .env File**
Create a `.env` file in the project root with:

```env
# Google Sheets API Configuration
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id_here
GOOGLE_SHEETS_CLIENT_EMAIL=your_service_account_email@your-project.iam.gserviceaccount.com
GOOGLE_SHEETS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key content here\n-----END PRIVATE KEY-----\n"
```

### 7. **Install Dependencies**
```bash
flutter pub get
```

### 8. **Run the App**
```bash
flutter run
```

## 🎯 What Recipients DON'T Need to Change

- ✅ No code modifications required
- ✅ No file structure changes needed
- ✅ No package dependencies to add
- ✅ Works with any Google Sheets document

## 📱 App Features

The app provides three main screens:

### **1. Morning Loadings** (Blue)
- Record products loaded into vehicles in the morning
- Data saved to "LOADINGS" sheet

### **2. Evening Returns** (Orange)
- Record unsold products returned in the evening
- Data saved to "RETURNS" sheet

### **3. Sales Reports** (Green)
- Automatically calculates sales: `Sales = Loading - Returns`
- Shows sales by date, driver, and vehicle
- Displays total sales per entry

## 🔧 Troubleshooting

### Common Issues:

1. **"Missing environment variables"**
   - Check that `.env` file exists and has correct values

2. **"Sheet not found"**
   - Ensure sheets are named exactly: "LOADINGS", "RETURNS"
   - Check service account has access to the spreadsheet

3. **"Authentication failed"**
   - Verify service account email and private key
   - Ensure Google Sheets API is enabled

4. **"Range parsing error"**
   - This has been fixed in the current version

## 📞 Support

If recipients encounter issues:
1. Check the `GOOGLE_SHEETS_SETUP.md` file for detailed setup instructions
2. Run `dart simple_diagnose.dart` to test the connection
3. Verify all environment variables are set correctly

## 🔒 Security Notes

- Never share the `.env` file
- Each user should create their own Google Cloud project
- Service account credentials should be kept secure
- The app only reads/writes to the specified Google Sheets document

## 🎉 Success!

Once set up, users can:
- Record morning loadings
- Record evening returns
- View automatic sales calculations
- Generate reports by date, driver, or vehicle

The system is now ready for production use! 🚀 