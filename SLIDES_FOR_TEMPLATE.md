# Presentation Content - Ready for Template Copy-Paste
## Using Google Sheets to Power Your Flutter App

**Instructions:** Copy the content for each slide into your Google Slides template. The content is formatted to be easily adaptable.

---

## 📄 SLIDE 1: TITLE SLIDE

**TITLE (Main Heading):**
Using Google Sheets to Power Your Flutter App

**SUBTITLE (Secondary Text):**
Your data, your app, all on Google Sheets.

**BODY/CONTENT:**
Busingye Anthony
DevFest Mbarara 2025
November 15, 2025

---

## 📄 SLIDE 2: THE REAL-WORLD PROBLEM

**TITLE:**
The Real-World Problem: Beverage Logistics

**BULLET POINTS:**
• Challenge: Manual record-keeping leads to:
  - Errors in calculations
  - Delays in sales reporting
  - Friction between drivers and management
  - No real-time visibility

• Goal: Build a simple, real-time solution to track:
  1. Loading - Cartons loaded per driver/vehicle
  2. Returns - Cartons returned per driver/vehicle
  3. Sales Calculation - Automatic calculation of sales

**SPEAKER NOTE:** Explain the business context: beverage distribution in Uganda. Emphasize this is a real problem you solved for a local business.

---

## 📄 SLIDE 3: WHY GOOGLE SHEETS?

**TITLE:**
Why Google Sheets? (The Low-Code Backend)

**BULLET POINTS:**
✓ Zero Server Costs - Completely bypass complex server infrastructure
✓ Familiarity - Data is instantly viewable/editable by managers in a spreadsheet
✓ Real-Time Data - Perfect for dynamic inventory or logistics tracking
✓ No Database Setup - No need for SQL, MongoDB, or Firebase setup
✓ Easy Collaboration - Multiple users can view/edit data simultaneously

**SPEAKER NOTE:** This is the "beyond documentation" insight: Google Sheets is a legitimate backend option. Explain when this approach is suitable (small to medium-scale apps).

---

## 📄 SLIDE 4: PREREQUISITES

**TITLE:**
Prerequisites

**BULLET POINTS:**
• Flutter SDK (2.0+)
• Google Account
• Google Cloud Console access
• IDE (VS Code / Android Studio)
• Basic understanding of:
  - Dart/Flutter
  - REST APIs
  - JSON

**SPEAKER NOTE:** Ask attendees to open Flutter and create a new project if they want to follow along.

---

## 📄 SLIDE 5: STEP 1 - STRUCTURING OUR BACKEND

**TITLE:**
Step 1: Structuring Our Backend (Google Sheet)

**BODY TEXT:**

Required Columns for LOGISTICS Sheet:

Date | Driver Name | Vehicle Number | B-Steady 24x200ml | B-Steady Pieces | B-Steady 12x200ml | Jim Pombe 24x200ml | Jim Pombe 12x200ml | Jim Pombe Pieces | Notes

**Sheet Structure:**
• Sheet 1: "LOADINGS" - Records of products loaded
• Sheet 2: "RETURNS" - Records of products returned
• (Optional) Sheet 3: "SALES" - Calculated sales data

**SPEAKER NOTE:** Show your actual Google Sheet to the audience. Explain why the structure is critical for simple data entry and calculation.

---

## 📄 SLIDE 6: STEP 2 - SECURING THE CONNECTION

**TITLE:**
Step 2: Securing the Connection

**BULLET POINTS:**

Authentication: Using Google Cloud Service Account

Why Service Account?
• Most reliable way to perform CRUD operations from Flutter
• No need for user sign-in (OAuth 2.0) in the app
• Perfect for automated systems and demos

Steps:
1. Go to Google Cloud Console
2. Create a new project (or select existing)
3. Enable Google Sheets API
4. Create Service Account
5. Generate JSON credentials file
6. Share your Google Sheet with the service account email

Security Best Practice:
• Never commit credentials to Git
• Use environment variables or secure storage

**SPEAKER NOTE:** Live demo: Show the Google Cloud Console. Show where to enable the API and download the JSON credentials file.

---

## 📄 SLIDE 7: STEP 3 - FLUTTER INTEGRATION

**TITLE:**
Step 3: Flutter Integration

**BODY TEXT:**

Packages Needed (pubspec.yaml):

dependencies:
  flutter:
    sdk: flutter
  googleapis: ^11.0.0
  googleapis_auth: ^1.4.1
  http: ^1.1.0
  intl: ^0.18.1

**Project Structure:**
lib/
  ├── services/
  │   └── google_sheets_service.dart
  ├── models/
  │   └── loading_return.dart
  └── screens/
      ├── loading_screen.dart
      ├── returns_screen.dart
      └── sales_screen.dart

---

## 📄 SLIDE 8: THE R IN CRUD - READING RECORDS

**TITLE:**
The R in CRUD: Reading Records

**CODE BLOCK (Use monospace font):**

Future<List<List<dynamic>>> getSheetData(String range) async {
  final response = await (await _api).spreadsheets.values.get(
    _spreadsheetId,
    range, // e.g., 'LOADINGS!A2:Z100'
  );
  return response.values ?? [];
}

**KEY POINTS:**
• Use spreadsheets.values.get() for reading
• Specify range: SheetName!A2:Z (skip header row)
• Handle empty responses gracefully
• Implement retry logic for network failures

**SPEAKER NOTE:** Live-code the fetchRecords() function. Show how to parse the data into Dart objects.

---

## 📄 SLIDE 9: THE C IN CRUD - CREATING RECORDS

**TITLE:**
The C in CRUD: Creating Records

**CODE BLOCK:**

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

**KEY POINTS:**
• Use spreadsheets.values.append() for adding rows
• valueInputOption: 'USER_ENTERED' - respects formulas
• Always include timestamp for auditing
• Validate data before sending

**SPEAKER NOTE:** Live-code the postRecord() function. Demonstrate adding a new row and show the data appearing in the actual Google Sheet in real-time.

---

## 📄 SLIDE 10: THE BUSINESS LOGIC - SALES CALCULATION

**TITLE:**
The Business Logic: Sales Calculation

**FORMULA:**
Sales = Total Cartons Loaded - Total Cartons Returned

**IMPLEMENTATION LOGIC:**
1. Fetch all LOADINGS records
2. Fetch all RETURNS records
3. Group by Driver/Product
4. Sum Loaded quantities
5. Sum Returned quantities
6. Calculate difference = Sales

**CODE STRUCTURE:**

Map<String, int> calculateSales(
  List<LoadingReturn> loadings, 
  List<LoadingReturn> returns
) {
  // Filter by driver/product
  // Sum quantities
  // Return sales map
}

**SPEAKER NOTE:** Walk through the calculation logic. Show how to iterate through records and filter by DriverName and Product.

---

## 📄 SLIDE 11: LIVE DEMO - THE COMPLETE APP

**TITLE:**
Live Demo: The Complete App

**FEATURES LIST:**
✓ Loading Screen - Record products loaded
✓ Returns Screen - Record products returned
✓ Sales Screen - View calculated sales
  - By Driver
  - By Product
  - Daily/Weekly/Monthly reports

**SPEAKER NOTE:** Show the app running on emulator/device. Demonstrate each screen. Show data syncing in real-time with Google Sheet.

---

## 📄 SLIDE 12: KEY SECURITY & SCALING INSIGHTS

**TITLE:**
Key Security & Scaling Insights (Beyond Documentation)

**LESSONS LEARNED:**

1. Data Validation
   ✓ Validate in Flutter (Dart) before sending to Sheets
   ✓ Use proper data types (int, String, DateTime)
   ✓ Implement form validation

2. Key Protection
   ✗ Never hardcode credentials
   ✓ Use environment variables (.env file)
   ✓ For web: Use Firebase Functions as proxy
   ✓ For mobile: Use Flutter Secure Storage

3. Performance Optimization
   ✓ Only fetch specific ranges (not entire sheet)
   ✓ Implement caching for frequently accessed data
   ✓ Use batch operations when possible
   ✓ Add retry logic with exponential backoff

4. Scaling Considerations
   ⚠ Google Sheets API has rate limits (100 requests/100 seconds/user)
   ⚠ Best for < 10,000 rows
   ⚠ Consider Firebase/MongoDB for larger datasets

**SPEAKER NOTE:** This is your "experience-based" content. Share real problems you encountered and explain workarounds that aren't in documentation.

---

## 📄 SLIDE 13: COMMON PITFALLS & SOLUTIONS

**TITLE:**
Common Pitfalls & Solutions

**PROBLEM 1: "Permission Denied" Error**
Solution: Ensure service account email has access to the Sheet
Share Sheet with service account email (not just your personal account)

**PROBLEM 2: "Invalid Range" Error**
Solution: Always validate sheet names exist
Use getSheetNames() before operations

**PROBLEM 3: Rate Limiting**
Solution: Implement retry logic with delays
Batch multiple operations when possible

**PROBLEM 4: Date Format Issues**
Solution: Standardize date format (YYYY-MM-DD)
Use intl package for parsing

**PROBLEM 5: Empty Cells**
Solution: Always check for null/empty values
Use ?? operator for defaults

**SPEAKER NOTE:** Share actual errors you encountered. Show screenshots of error messages and explain how you debugged them.

---

## 📄 SLIDE 14: WHEN TO USE THIS APPROACH

**TITLE:**
When to Use Google Sheets as Backend

**PERFECT FOR:**
✓ Small to medium businesses
✓ MVP/Prototype development
✓ Internal tools and dashboards
✓ Data collection apps
✓ Simple inventory systems
✓ Low-traffic applications (< 1000 users)

**NOT SUITABLE FOR:**
✗ High-traffic applications
✗ Complex relational data
✗ Real-time collaboration features
✗ Large datasets (> 10,000 rows)
✗ Applications requiring transactions
✗ High-security requirements

**MIGRATION PATH:**
Start with Google Sheets → Migrate to Firebase/MongoDB when needed → Keep the same Flutter app structure

**SPEAKER NOTE:** Be honest about limitations. Help attendees make informed decisions.

---

## 📄 SLIDE 15: ALTERNATIVE USE CASES

**TITLE:**
Other Real-World Applications

**USE CASES:**
• Event Registration - Track attendees and check-ins
• Inventory Management - Stock levels and alerts
• Survey/Feedback Collection - Forms data collection
• Team Collaboration - Shared task lists
• Content Management - Dynamic app content
• Analytics Dashboard - Business metrics tracking
• Lead Management - CRM for small businesses

**SPEAKER NOTE:** Encourage attendees to think of their own use cases. Mention that the same pattern applies to all.

---

## 📄 SLIDE 16: RESOURCES & NEXT STEPS

**TITLE:**
Resources & Next Steps

**DOCUMENTATION:**
• Google Sheets API: https://developers.google.com/sheets/api
• Flutter Packages: https://pub.dev/packages/googleapis
• Service Account Setup: (Your custom guide)

**CODE REPOSITORY:**
• GitHub: [Your repo link - if public]
• Demo Project: Available for download

**NEXT STEPS:**
1. Set up your Google Cloud project
2. Create a test Sheet
3. Build your first CRUD operation
4. Share your project with the community!

**SPEAKER NOTE:** Provide links to resources. Offer to share slides/code after the event.

---

## 📄 SLIDE 17: THANK YOU & CONNECT

**TITLE:**
Thank You!

**CONTACT INFORMATION:**
Speaker: Busingye Anthony
Email: [Your email]
X/Twitter: [Your handle]
LinkedIn: [Your profile]

**HASHTAGS:**
#DevFestMbarara2025
#FlutterDev
#GoogleSheets
#LowCodeBackend

**Q&A SESSION**

**SPEAKER NOTE:** Thank the organizers and attendees. Open the floor for questions. Be available after the session for one-on-one discussions.

---

## 📝 COPY-PASTE INSTRUCTIONS FOR GOOGLE SLIDES:

1. Open your Google Slides template
2. For each slide above:
   - Copy the TITLE text → Paste into title placeholder
   - Copy BULLET POINTS or BODY TEXT → Paste into content area
   - For CODE BLOCKS: Use Insert → Code block or format as monospace text
   - Adjust font sizes and formatting to match your template style
3. Add images/visuals where suggested
4. Use speaker notes section for SPEAKER NOTE content

---

## 🎨 TEMPLATE CUSTOMIZATION TIPS:

If you can share these details about your template, I can provide more specific formatting:
- Primary color (hex code)
- Secondary color
- Font family for headings
- Font family for body text
- Any specific layout requirements
- Code block formatting preferences

---

**Good luck with your presentation! 🚀**



