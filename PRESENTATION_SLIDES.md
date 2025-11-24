 # DevFest Mbarara 2025 - Presentation Slides
## Using Google Sheets to Power Your Flutter App

**Speaker:** Busingye Anthony  
**Event:** DevFest Mbarara 2025  
**Format:** 45-minute Workshop  
**Date:** November 15, 2025

---

## SLIDE 1: Title Slide

**Title:** Using Google Sheets to Power Your Flutter App

**Subtitle:** Your data, your app, all on Google Sheets.

**Content:**
- Busingye Anthony
- DevFest Mbarara 2025
- November 15, 2025

**Speaker Notes:**
- Welcome everyone and introduce yourself briefly
- Mention this is a hands-on workshop where we'll build a real-world solution

---

## SLIDE 2: The Real-World Problem

**Title:** The Real-World Problem: Beverage Logistics

**Content:**
- **Challenge:** Manual record-keeping leads to:
  - ❌ Errors in calculations
  - ❌ Delays in sales reporting
  - ❌ Friction between drivers and management
  - ❌ No real-time visibility

- **Goal:** Build a simple, real-time solution to track:
  1. **Loading** - Cartons loaded per driver/vehicle
  2. **Returns** - Cartons returned per driver/vehicle
  3. **Sales Calculation** - Automatic calculation of sales

**Visual Suggestion:**
- Image of beverage crates or delivery truck
- Diagram showing the flow: Loading → Returns → Sales

**Speaker Notes:**
- Explain the business context: beverage distribution in Uganda
- Emphasize this is a real problem you solved for a local business
- Set the expectation that we'll build this solution together

---

## SLIDE 3: Why Google Sheets?

**Title:** Why Google Sheets? (The Low-Code Backend)

**Content:**
- ✅ **Zero Server Costs** - Completely bypass complex server infrastructure
- ✅ **Familiarity** - Data is instantly viewable/editable by managers in a spreadsheet
- ✅ **Real-Time Data** - Perfect for dynamic inventory or logistics tracking
- ✅ **No Database Setup** - No need for SQL, MongoDB, or Firebase setup
- ✅ **Easy Collaboration** - Multiple users can view/edit data simultaneously

**Visual Suggestion:**
- Comparison diagram: Traditional Backend vs Google Sheets
- Show a simple Google Sheet interface

**Speaker Notes:**
- This is the "beyond documentation" insight: Google Sheets is a legitimate backend option
- Explain when this approach is suitable (small to medium-scale apps)
- Mention when it might NOT be suitable (high traffic, complex queries)

---

## SLIDE 4: Prerequisites

**Title:** Prerequisites

**Content:**
- Flutter SDK (2.0+)
- Google Account
- Google Cloud Console access
- IDE (VS Code / Android Studio)
- Basic understanding of:
  - Dart/Flutter
  - REST APIs
  - JSON

**Speaker Notes:**
- Ask attendees to open Flutter and create a new project if they want to follow along
- Mention that you'll have a backup demo ready if live coding fails

---

## SLIDE 5: Step 1 - Structuring Our Backend

**Title:** Step 1: Structuring Our Backend (Google Sheet)

**Content:**
**Required Columns for LOGISTICS Sheet:**

| Column | Description |
|--------|-------------|
| Date | Transaction date (YYYY-MM-DD) |
| Driver Name | Name of the driver |
| Vehicle Number | Vehicle registration |
| B-Steady 24x200ml | Product quantity |
| B-Steady Pieces | Product quantity |
| B-Steady 12x200ml | Product quantity |
| Jim Pombe 24x200ml | Product quantity |
| Jim Pombe 12x200ml | Product quantity |
| Jim Pombe Pieces | Product quantity |
| Notes | Additional information |

**Sheet Structure:**
- **Sheet 1:** "LOADINGS" - Records of products loaded
- **Sheet 2:** "RETURNS" - Records of products returned
- (Optional) **Sheet 3:** "SALES" - Calculated sales data

**Speaker Notes:**
- Show your actual Google Sheet to the audience
- Explain why the structure is critical for simple data entry and calculation
- Emphasize: Good data structure = easier app development

---

## SLIDE 6: Step 2 - Securing the Connection

**Title:** Step 2: Securing the Connection

**Content:**
**Authentication: Using Google Cloud Service Account**

**Why Service Account?**
- Most reliable way to perform CRUD operations from Flutter
- No need for user sign-in (OAuth 2.0) in the app
- Perfect for automated systems and demos

**Steps:**
1. Go to Google Cloud Console
2. Create a new project (or select existing)
3. Enable Google Sheets API
4. Create Service Account
5. Generate JSON credentials file
6. Share your Google Sheet with the service account email

**Security Best Practice:**
- Never commit credentials to Git
- Use environment variables or secure storage

**Speaker Notes:**
- Live demo: Show the Google Cloud Console (or use screenshots)
- Show where to enable the API
- Show how to download the JSON credentials file
- **Critical:** Explain how to share the Sheet with the service account email

---

## SLIDE 7: Step 3 - Flutter Integration

**Title:** Step 3: Flutter Integration

**Content:**
**Packages Needed (pubspec.yaml):**

```yaml
dependencies:
  flutter:
    sdk: flutter
  googleapis: ^11.0.0
  googleapis_auth: ^1.4.1
  http: ^1.1.0
  intl: ^0.18.1
```

**Project Structure:**
```
lib/
  ├── services/
  │   └── google_sheets_service.dart
  ├── models/
  │   └── loading_return.dart
  └── screens/
      ├── loading_screen.dart
      ├── returns_screen.dart
      └── sales_screen.dart
```

**Speaker Notes:**
- Show the Flutter project setup
- Explain the service layer pattern
- Show where to securely store credentials (environment variables)

---

## SLIDE 8: The R in CRUD - Reading Records

**Title:** The R in CRUD: Reading Records

**Content:**
**Code Example:**

```dart
Future<List<List<dynamic>>> getSheetData(String range) async {
  final response = await (await _api).spreadsheets.values.get(
    _spreadsheetId,
    range, // e.g., 'LOADINGS!A2:Z100'
  );
  return response.values ?? [];
}
```

**Key Points:**
- Use `spreadsheets.values.get()` for reading
- Specify range: `SheetName!A2:Z` (skip header row)
- Handle empty responses gracefully
- Implement retry logic for network failures

**Speaker Notes:**
- Live-code the `fetchRecords()` function
- Show how to parse the data into Dart objects
- Run the app to confirm data loads successfully
- Show the data in a ListView

---

## SLIDE 9: The C in CRUD - Creating Records

**Title:** The C in CRUD: Creating Records

**Content:**
**Code Example:**

```dart
Future<void> appendRow(String range, List<dynamic> row) async {
  final valueRange = ValueRange()..values = [row];
  await (await _api).spreadsheets.values.append(
    valueRange,
    _spreadsheetId,
    range,
    valueInputOption: 'USER_ENTERED',
    insertDataOption: 'INSERT_ROWS',
  );
}
```

**Key Points:**
- Use `spreadsheets.values.append()` for adding rows
- `valueInputOption: 'USER_ENTERED'` - respects formulas
- Always include timestamp for auditing
- Validate data before sending

**Speaker Notes:**
- Live-code the `postRecord()` function
- Show a form with Driver, Vehicle, Product quantities
- Demonstrate adding a new row
- Show the data appearing in the actual Google Sheet in real-time
- This is the "wow" moment!

---

## SLIDE 10: The Business Logic - Sales Calculation

**Title:** The Business Logic: Sales Calculation

**Content:**
**Formula:**
```
Sales = Total Cartons Loaded - Total Cartons Returned
```

**Implementation Logic:**
1. Fetch all LOADINGS records
2. Fetch all RETURNS records
3. Group by Driver/V product
4. Sum Loaded quantities
5. Sum Returned quantities
6. Calculate difference = Sales

**Code Structure:**
```dart
Map<String, int> calculateSales(List<LoadingReturn> loadings, 
                                List<LoadingReturn> returns) {
  // Filter by driver/product
  // Sum quantities
  // Return sales map
}
```

**Speaker Notes:**
- Walk through the calculation logic
- Show how to iterate through records
- Filter by DriverName and Product
- Display the final Sales number in the app
- Emphasize: Business logic stays in Flutter, Sheets is just storage

---

## SLIDE 11: Live Demo - The Complete App

**Title:** Live Demo: The Complete App

**Content:**
**Features:**
1. ✅ **Loading Screen** - Record products loaded
2. ✅ **Returns Screen** - Record products returned
3. ✅ **Sales Screen** - View calculated sales
   - By Driver
   - By Product
   - Daily/Weekly/Monthly reports

**Visual:**
- Show the app running on emulator/device
- Demonstrate each screen
- Show data syncing in real-time with Google Sheet

**Speaker Notes:**
- This is where you showcase the complete working app
- Switch between the app and the Google Sheet to show real-time sync
- Point out the UI/UX features
- Show how managers can view/edit data directly in Sheets

---

## SLIDE 12: Key Security & Scaling Insights

**Title:** Key Security & Scaling Insights (Beyond Documentation)

**Content:**
**Lessons Learned:**

1. **Data Validation**
   - ✅ Validate in Flutter (Dart) before sending to Sheets
   - ✅ Use proper data types (int, String, DateTime)
   - ✅ Implement form validation

2. **Key Protection**
   - ❌ Never hardcode credentials
   - ✅ Use environment variables (.env file)
   - ✅ For web: Use Firebase Functions as proxy
   - ✅ For mobile: Use Flutter Secure Storage

3. **Performance Optimization**
   - ✅ Only fetch specific ranges (not entire sheet)
   - ✅ Implement caching for frequently accessed data
   - ✅ Use batch operations when possible
   - ✅ Add retry logic with exponential backoff

4. **Scaling Considerations**
   - ⚠️ Google Sheets API has rate limits (100 requests/100 seconds/user)
   - ⚠️ Best for < 10,000 rows
   - ⚠️ Consider Firebase/MongoDB for larger datasets

**Speaker Notes:**
- This is your "experience-based" content
- Share real problems you encountered
- Explain workarounds that aren't in documentation
- Be honest about limitations

---

## SLIDE 13: Common Pitfalls & Solutions

**Title:** Common Pitfalls & Solutions

**Content:**
**Problem 1: "Permission Denied" Error**
- **Solution:** Ensure service account email has access to the Sheet
- Share Sheet with service account email (not just your personal account)

**Problem 2: "Invalid Range" Error**
- **Solution:** Always validate sheet names exist
- Use `getSheetNames()` before operations

**Problem 3: Rate Limiting**
- **Solution:** Implement retry logic with delays
- Batch multiple operations when possible

**Problem 4: Date Format Issues**
- **Solution:** Standardize date format (YYYY-MM-DD)
- Use `intl` package for parsing

**Problem 5: Empty Cells**
- **Solution:** Always check for null/empty values
- Use `??` operator for defaults

**Speaker Notes:**
- Share actual errors you encountered
- Show screenshots of error messages
- Explain how you debugged them

---

## SLIDE 14: When to Use This Approach

**Title:** When to Use Google Sheets as Backend

**Content:**
**✅ Perfect For:**
- Small to medium businesses
- MVP/Prototype development
- Internal tools and dashboards
- Data collection apps
- Simple inventory systems
- Low-traffic applications (< 1000 users)

**❌ Not Suitable For:**
- High-traffic applications
- Complex relational data
- Real-time collaboration features
- Large datasets (> 10,000 rows)
- Applications requiring transactions
- High-security requirements

**Migration Path:**
- Start with Google Sheets
- Migrate to Firebase/MongoDB when needed
- Keep the same Flutter app structure

**Speaker Notes:**
- Be honest about limitations
- Help attendees make informed decisions
- Show the migration path if they outgrow Sheets

---

## SLIDE 15: Alternative Use Cases

**Title:** Other Real-World Applications

**Content:**
- **Event Registration** - Track attendees and check-ins
- **Inventory Management** - Stock levels and alerts
- **Survey/Feedback Collection** - Forms data collection
- **Team Collaboration** - Shared task lists
- **Content Management** - Dynamic app content
- **Analytics Dashboard** - Business metrics tracking
- **Lead Management** - CRM for small businesses

**Speaker Notes:**
- Encourage attendees to think of their own use cases
- Mention that the same pattern applies to all
- Challenge them to build something for their community

---

## SLIDE 16: Resources & Next Steps

**Title:** Resources & Next Steps

**Content:**
**Documentation:**
- Google Sheets API: https://developers.google.com/sheets/api
- Flutter Packages: https://pub.dev/packages/googleapis
- Service Account Setup: (Your custom guide)

**Code Repository:**
- GitHub: [Your repo link - if public]
- Demo Project: Available for download

**Next Steps:**
1. Set up your Google Cloud project
2. Create a test Sheet
3. Build your first CRUD operation
4. Share your project with the community!

**Speaker Notes:**
- Provide links to resources
- Offer to share slides/code after the event
- Invite questions during Q&A

---

## SLIDE 17: Thank You & Connect

**Title:** Thank You!

**Content:**
- **Speaker:** Busingye Anthony
- **Email:** [Your email]
- **X/Twitter:** [Your handle]
- **LinkedIn:** [Your profile]

**Hashtags:**
- #DevFestMbarara2025
- #FlutterDev
- #GoogleSheets
- #LowCodeBackend

**Q&A Session**

**Speaker Notes:**
- Thank the organizers
- Thank the attendees for their time
- Open the floor for questions
- Be available after the session for one-on-one discussions

---

## APPENDIX: Code Snippets for Reference

### Complete Google Sheets Service (Key Methods)

```dart
class GoogleSheetsService {
  final String _spreadsheetId;
  final String _clientEmail;
  final String _privateKey;
  SheetsApi? _sheetsApi;

  // Initialize API
  Future<SheetsApi> get _api async {
    if (_sheetsApi == null) {
      final credentials = ServiceAccountCredentials.fromJson({
        'type': 'service_account',
        'private_key': _privateKey,
        'client_email': _clientEmail,
      });
      
      final client = await clientViaServiceAccount(
        credentials,
        [SheetsApi.spreadsheetsScope],
      );
      
      _sheetsApi = SheetsApi(client);
    }
    return _sheetsApi!;
  }

  // Read data
  Future<List<List<dynamic>>> getSheetData(String range) async {
    final response = await (await _api).spreadsheets.values.get(
      _spreadsheetId,
      range,
    );
    return response.values ?? [];
  }

  // Append row
  Future<void> appendRow(String range, List<dynamic> row) async {
    final valueRange = ValueRange()..values = [row];
    await (await _api).spreadsheets.values.append(
      valueRange,
      _spreadsheetId,
      range,
      valueInputOption: 'USER_ENTERED',
    );
  }
}
```

### Data Model Example

```dart
class LoadingReturn {
  final DateTime date;
  final String driverName;
  final String vehicleNumber;
  final Map<String, int> productQuantities;

  // Convert to Sheets row
  List<String> toSheetsRow() {
    return [
      DateFormat('yyyy-MM-dd').format(date),
      driverName,
      vehicleNumber,
      ...productQuantities.values.map((v) => v.toString()),
    ];
  }
}
```

---

## PRESENTATION TIPS

1. **Timing:**
   - Introduction: 5 min
   - Setup & Backend: 10 min
   - Live Coding: 20 min
   - Demo & Insights: 8 min
   - Q&A: 2 min

2. **Backup Plan:**
   - Have a pre-recorded video of the demo
   - Have the completed app running in an emulator
   - Have screenshots ready if live coding fails

3. **Code Presentation:**
   - Use large font size (24-28pt)
   - Use high-contrast theme (dark mode)
   - Explain each line as you type
   - Pause for questions

4. **Engagement:**
   - Ask questions: "Has anyone used Google Sheets API before?"
   - Show real data from your actual app
   - Encourage attendees to try along
   - Be enthusiastic about the solution

5. **Technical Setup:**
   - Test internet connection before session
   - Have credentials pre-configured
   - Test on the actual projector/screen
   - Have backup slides in PDF format

---

## FINAL CHECKLIST

Before the presentation:
- [ ] All slides created in 16:9 format
- [ ] Code snippets tested and working
- [ ] Demo app ready and tested
- [ ] Backup demo/video prepared
- [ ] Credentials secured (not in slides)
- [ ] Internet connection tested
- [ ] Slides exported to PDF backup
- [ ] Speaker notes reviewed
- [ ] Time yourself going through the presentation

Good luck with your presentation! 🚀

