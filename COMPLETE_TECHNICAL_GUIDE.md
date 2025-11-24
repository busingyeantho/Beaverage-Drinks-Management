# Complete Technical Guide: Google Sheets to Flutter Connection
## Step-by-Step Master Guide for Your Presentation

---

## 🎯 OVERVIEW

This guide covers the **complete technical process** from zero to a working Flutter app connected to Google Sheets. Follow these steps in order.

---

## PART 1: GOOGLE CLOUD CONSOLE SETUP

### Step 1: Create a Google Cloud Project

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click the project dropdown at the top
   - Click "New Project"
   - **Project Name:** `beverage-logistics` (or any name)
   - Click "Create"
   - Wait for project creation (30 seconds)

3. **Select Your Project**
   - Make sure your new project is selected in the dropdown

**Why:** You need a project to enable APIs and create credentials.

---

### Step 2: Enable Google Sheets API

1. **Navigate to APIs & Services**
   - In the left sidebar, click "APIs & Services"
   - Click "Library"

2. **Search for Google Sheets API**
   - In the search bar, type: "Google Sheets API"
   - Click on "Google Sheets API" from results

3. **Enable the API**
   - Click the blue "Enable" button
   - Wait for activation (10-20 seconds)
   - You'll see "API enabled" confirmation

**Why:** Your app needs permission to access Google Sheets API.

---

### Step 3: Create Service Account

1. **Go to Credentials**
   - In the left sidebar, click "APIs & Services"
   - Click "Credentials"

2. **Create Service Account**
   - Click "+ CREATE CREDENTIALS" at the top
   - Select "Service account" from dropdown

3. **Fill Service Account Details**
   - **Service account name:** `beverage-sheets-service`
   - **Service account ID:** (auto-generated, keep it)
   - **Description:** `Service account for beverage logistics app`
   - Click "CREATE AND CONTINUE"

4. **Skip Optional Steps**
   - Click "CONTINUE" (skip role assignment)
   - Click "DONE" (skip user access)

**Why:** Service Account is a special account that represents your app, not a user.

---

### Step 4: Generate JSON Credentials

1. **Open Your Service Account**
   - In the Credentials page, find your service account
   - Click on the service account email (ends with `@project-id.iam.gserviceaccount.com`)

2. **Go to Keys Tab**
   - Click the "KEYS" tab at the top

3. **Create New Key**
   - Click "ADD KEY"
   - Select "Create new key"
   - Choose "JSON" format
   - Click "CREATE"

4. **Download JSON File**
   - A JSON file will automatically download
   - **IMPORTANT:** Save this file securely
   - **DO NOT** commit this file to Git!

**The JSON file looks like this:**
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n",
  "client_email": "beverage-sheets-service@your-project-id.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

**Extract These Values:**
- `client_email` - The service account email
- `private_key` - The private key (keep the `\n` characters)

**Why:** These credentials authenticate your app with Google Sheets API.

---

## PART 2: GOOGLE SHEET SETUP

### Step 5: Create Your Google Sheet

1. **Create New Sheet**
   - Go to: https://sheets.google.com/
   - Click "Blank" to create a new spreadsheet

2. **Name Your Sheet**
   - Click "Untitled spreadsheet" at the top
   - Rename to: "Beverage Logistics"

3. **Get Spreadsheet ID**
   - Look at the URL: `https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit`
   - Copy the `SPREADSHEET_ID` (the long string between `/d/` and `/edit`)
   - Example: `1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms`
   - **Save this ID** - you'll need it!

**Why:** The Spreadsheet ID identifies which sheet your app will access.

---

### Step 6: Structure Your Sheet

1. **Create Sheet Tabs**
   - At the bottom, rename "Sheet1" to "LOADINGS"
   - Click "+" to add a new sheet, name it "RETURNS"

2. **Set Up Headers (LOADINGS Sheet)**
   - In Row 1, add these headers:
   ```
   A1: Date
   B1: Driver Name
   C1: Vehicle Number
   D1: B-Steady 24x200ml
   E1: B-Steady Pieces
   F1: B-Steady 12x200ml
   G1: Jim Pombe 24x200ml
   H1: Jim Pombe 12x200ml
   I1: Jim Pombe Pieces
   J1: Notes
   ```

3. **Set Up Headers (RETURNS Sheet)**
   - Same headers as LOADINGS sheet

**Why:** Proper structure makes data easy to read and write programmatically.

---

### Step 7: Share Sheet with Service Account

**THIS IS THE CRITICAL STEP MANY PEOPLE MISS!**

1. **Click Share Button**
   - In your Google Sheet, click the blue "Share" button (top right)

2. **Add Service Account Email**
   - In the "Add people and groups" field, paste your **service account email**
   - Example: `beverage-sheets-service@your-project-id.iam.gserviceaccount.com`
   - (This is the `client_email` from your JSON file)

3. **Set Permissions**
   - Change permission from "Viewer" to **"Editor"**
   - **DO NOT** check "Notify people" (service account doesn't have email)

4. **Click "Share"**
   - Even though it says "Send", just click it
   - The service account now has access

**Why:** Without this step, your app will get "Permission Denied" errors!

**Verification:**
- Go back to your sheet
- Click "Share" again
- You should see the service account email listed as an editor

---

## PART 3: FLUTTER PROJECT SETUP

### Step 8: Create Flutter Project

1. **Create New Flutter Project**
   ```bash
   flutter create beverage_logistics
   cd beverage_logistics
   ```

2. **Or use your existing project**

---

### Step 9: Add Dependencies

1. **Open `pubspec.yaml`**

2. **Add These Dependencies:**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     googleapis: ^12.0.0
     googleapis_auth: ^1.4.1
     http: ^1.1.0
     flutter_dotenv: ^5.1.0
     intl: ^0.19.0
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

**Why:** These packages provide Google Sheets API access and authentication.

---

### Step 10: Create Environment File

1. **Create `.env` File**
   - In your project root, create a file named `.env`

2. **Add Your Credentials:**
   ```env
   GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id_here
   GOOGLE_SHEETS_CLIENT_EMAIL=beverage-sheets-service@your-project-id.iam.gserviceaccount.com
   GOOGLE_SHEETS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"
   ```

3. **Replace with Your Actual Values:**
   - `GOOGLE_SHEETS_SPREADSHEET_ID`: From Step 5
   - `GOOGLE_SHEETS_CLIENT_EMAIL`: From JSON file (Step 4)
   - `GOOGLE_SHEETS_PRIVATE_KEY`: From JSON file (Step 4) - **Keep the quotes and \n characters!**

4. **Add `.env` to `.gitignore`**
   ```
   .env
   *.env
   ```

**Why:** Environment variables keep credentials secure and out of your code.

---

### Step 11: Update pubspec.yaml for Assets

1. **Add `.env` to Assets:**
   ```yaml
   flutter:
     assets:
       - .env
   ```

2. **Run:**
   ```bash
   flutter pub get
   ```

**Why:** Flutter needs to know about the `.env` file.

---

## PART 4: CREATE GOOGLE SHEETS SERVICE

### Step 12: Create Service File

1. **Create Directory:**
   ```
   lib/services/
   ```

2. **Create File:**
   ```
   lib/services/google_sheets_service.dart
   ```

---

### Step 13: Implement the Service Class

**Copy this complete working code:**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  // Step 1: Get credentials from environment
  final String _spreadsheetId;
  final String _clientEmail;
  final String _privateKey;
  bool _isConfigured = false;

  GoogleSheetsService()
      : _spreadsheetId = dotenv.env['GOOGLE_SHEETS_SPREADSHEET_ID'] ?? '',
        _clientEmail = dotenv.env['GOOGLE_SHEETS_CLIENT_EMAIL'] ?? '',
        _privateKey = (dotenv.env['GOOGLE_SHEETS_PRIVATE_KEY'] ?? '')
            .replaceAll(r'\n', '\n') {
    _validateEnvironment();
  }

  // Step 2: Validate that all credentials are present
  void _validateEnvironment() {
    _isConfigured = _spreadsheetId.isNotEmpty &&
        _clientEmail.isNotEmpty &&
        _privateKey.isNotEmpty;

    if (!_isConfigured) {
      debugPrint('⚠️ Google Sheets not fully configured!');
      debugPrint('Missing: ${_spreadsheetId.isEmpty ? 'SPREADSHEET_ID ' : ''}'
          '${_clientEmail.isEmpty ? 'CLIENT_EMAIL ' : ''}'
          '${_privateKey.isEmpty ? 'PRIVATE_KEY' : ''}');
    } else {
      debugPrint('✅ Google Sheets configured successfully');
    }
  }

  // Step 3: Build credentials object for Service Account
  Map<String, dynamic> get _credentials => {
        'type': 'service_account',
        'private_key': _privateKey,
        'client_email': _clientEmail,
        'client_id': _clientEmail.split('@').first,
        'token_uri': 'https://oauth2.googleapis.com/token',
      };

  // Step 4: Define API scopes (what permissions we need)
  static const _scopes = [SheetsApi.spreadsheetsScope];

  // Step 5: Store API client instances
  SheetsApi? _sheetsApi;
  AutoRefreshingAuthClient? _client;

  // Step 6: Get or initialize the API instance
  Future<SheetsApi> get _api async {
    if (!_isConfigured) {
      throw Exception('Google Sheets is not configured. Check your .env file.');
    }

    if (_sheetsApi == null) {
      await _initialize();
    }

    return _sheetsApi!;
  }

  // Step 7: THE KEY METHOD - Initialize Service Account Authentication
  Future<void> _initialize() async {
    try {
      debugPrint('🔄 Initializing Google Sheets API...');

      // Create Service Account credentials from JSON
      final credentials = ServiceAccountCredentials.fromJson(_credentials);

      // Authenticate using Service Account
      // This is the magic that makes it work!
      _client = await clientViaServiceAccount(
        credentials,
        _scopes,
        baseClient: http.Client(),
      );

      // Create Sheets API instance with authenticated client
      _sheetsApi = SheetsApi(_client!);

      debugPrint('✅ Google Sheets API initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Google Sheets API: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Step 8: READ - Get data from sheet
  Future<List<List<dynamic>>> getSheetData(String range) async {
    try {
      debugPrint('📖 Reading data from range: $range');

      final response = await (await _api).spreadsheets.values.get(
            _spreadsheetId,
            range, // e.g., 'LOADINGS!A2:Z'
          );

      final data = response.values ?? [];
      debugPrint('✅ Read ${data.length} rows from sheet');
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to read sheet data: $e');
      rethrow;
    }
  }

  // Step 9: CREATE - Append new row to sheet
  Future<void> appendRow(String range, List<dynamic> row) async {
    try {
      debugPrint('➕ Appending row to range: $range');

      final valueRange = ValueRange()..values = [row];

      await (await _api).spreadsheets.values.append(
            valueRange,
            _spreadsheetId,
            range,
            valueInputOption: 'USER_ENTERED',
            insertDataOption: 'INSERT_ROWS',
          );

      debugPrint('✅ Row appended successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to append row: $e');
      rethrow;
    }
  }

  // Step 10: UPDATE - Update existing row
  Future<void> updateRow(String range, List<dynamic> row) async {
    try {
      debugPrint('✏️ Updating row in range: $range');

      final valueRange = ValueRange()..values = [row];

      await (await _api).spreadsheets.values.update(
            valueRange,
            _spreadsheetId,
            range,
            valueInputOption: 'USER_ENTERED',
          );

      debugPrint('✅ Row updated successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to update row: $e');
      rethrow;
    }
  }

  // Step 11: DELETE - Delete row by index
  Future<void> deleteRow(String sheetName, int rowIndex) async {
    try {
      debugPrint('🗑️ Deleting row $rowIndex from sheet: $sheetName');

      // Get spreadsheet to find sheet ID
      final spreadsheet = await (await _api).spreadsheets.get(_spreadsheetId);
      final sheet = spreadsheet.sheets?.firstWhere(
        (s) => s.properties?.title == sheetName,
        orElse: () => throw Exception('Sheet "$sheetName" not found'),
      );

      final sheetId = sheet!.properties!.sheetId!;

      // Create delete request
      final dimensionRange = DimensionRange()
        ..sheetId = sheetId
        ..dimension = 'ROWS'
        ..startIndex = rowIndex - 1 // Convert to 0-based
        ..endIndex = rowIndex;

      final request = BatchUpdateSpreadsheetRequest()
        ..requests = [
          Request()
            ..deleteDimension = DeleteDimensionRequest()..range = dimensionRange
        ];

      await (await _api).spreadsheets.batchUpdate(request, _spreadsheetId);

      debugPrint('✅ Row deleted successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to delete row: $e');
      rethrow;
    }
  }
}
```

**Key Points:**
- `_initialize()` is where Service Account authentication happens
- `clientViaServiceAccount()` is the critical method
- All operations use the authenticated `_api` instance

---

## PART 5: INITIALIZE IN YOUR APP

### Step 14: Load Environment Variables

**In `main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}
```

**Why:** Load credentials before the app starts.

---

### Step 15: Use the Service

**Example in a screen:**

```dart
import 'package:flutter/material.dart';
import '../services/google_sheets_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final _googleSheetsService = GoogleSheetsService();
  List<List<dynamic>> _data = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // READ data
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _googleSheetsService.getSheetData('LOADINGS!A2:Z');
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // CREATE data
  Future<void> _submitForm() async {
    setState(() => _isLoading = true);
    try {
      final row = [
        DateTime.now().toString().split(' ')[0], // Date
        'Driver Name',
        'Vehicle Number',
        '100', // Quantity
      ];

      await _googleSheetsService.appendRow('LOADINGS!A:Z', row);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully!')),
      );

      await _loadData(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Records')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_data[index][1].toString()),
                  subtitle: Text(_data[index][2].toString()),
                );
              },
            ),
    );
  }
}
```

---

## PART 6: TESTING & VERIFICATION

### Step 16: Test the Connection

1. **Run Your App:**
   ```bash
   flutter run
   ```

2. **Check Console Output:**
   - Look for: `✅ Google Sheets configured successfully`
   - Look for: `✅ Google Sheets API initialized successfully`

3. **Test READ Operation:**
   - App should load data from your sheet
   - Check console for: `✅ Read X rows from sheet`

4. **Test CREATE Operation:**
   - Submit a form
   - Check console for: `✅ Row appended successfully`
   - **Go to your Google Sheet** - you should see the new row!

5. **Verify in Google Sheet:**
   - Open your Google Sheet in browser
   - You should see new data appearing in real-time!

---

## 🔍 TROUBLESHOOTING

### Error: "Permission Denied"
**Solution:**
- Go back to Step 7
- Make sure you shared the sheet with the service account email
- Verify the service account has "Editor" permissions

### Error: "Invalid grant: account not found"
**Solution:**
- Check your `client_email` in `.env` file
- Make sure it matches the service account email exactly
- Should end with `@project-id.iam.gserviceaccount.com`

### Error: "API not enabled"
**Solution:**
- Go back to Step 2
- Make sure Google Sheets API is enabled in your project

### Error: "Invalid range"
**Solution:**
- Check your sheet name (e.g., "LOADINGS" not "LOADING")
- Verify the range format: `SheetName!A2:Z`

### Error: "Failed to initialize"
**Solution:**
- Check your `private_key` in `.env` file
- Make sure it includes `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`
- Keep the `\n` characters (they're converted to newlines)

---

## 📋 COMPLETE CHECKLIST

Before presenting, verify:

- [ ] Google Cloud project created
- [ ] Google Sheets API enabled
- [ ] Service Account created
- [ ] JSON credentials downloaded
- [ ] Google Sheet created
- [ ] Sheet shared with service account email
- [ ] `.env` file created with correct values
- [ ] Dependencies added to `pubspec.yaml`
- [ ] `GoogleSheetsService` class created
- [ ] Environment variables loaded in `main.dart`
- [ ] Test READ operation - works!
- [ ] Test CREATE operation - works!
- [ ] Data appears in Google Sheet - verified!

---

## 🎯 KEY TAKEAWAYS FOR PRESENTATION

1. **Service Account is the Key**
   - Not OAuth2 (that's for user authentication)
   - Service Account = automated system authentication

2. **The Critical Step Everyone Misses**
   - Sharing the Google Sheet with service account email
   - Without this, you get "Permission Denied"

3. **The Magic Method**
   - `clientViaServiceAccount()` - this is what makes it work
   - Handles authentication automatically
   - No user interaction needed

4. **Environment Variables**
   - Keep credentials secure
   - Never commit `.env` to Git
   - Use `.gitignore`

---

## 📚 PRESENTATION FLOW

When presenting, follow this order:

1. **Show the Problem** (2 min)
   - Manual record-keeping issues

2. **Show the Solution** (1 min)
   - Google Sheets as backend

3. **Live Setup** (10 min)
   - Google Cloud Console (Steps 1-4)
   - Google Sheet setup (Steps 5-7)
   - Show sharing the sheet (CRITICAL!)

4. **Live Coding** (15 min)
   - Create Flutter service (Steps 8-13)
   - Show the `_initialize()` method
   - Test READ operation
   - Test CREATE operation
   - Show data appearing in Google Sheet!

5. **Key Insights** (5 min)
   - Service Account vs OAuth2
   - Common mistakes
   - Best practices

---

**You now have the complete technical mastery! 🚀**

