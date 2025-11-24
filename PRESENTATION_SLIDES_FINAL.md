# DevFest Mbarara 2025 - Final Presentation Slides
## Using Google Sheets to Power Your Flutter App

**Speaker:** Busingye Anthony  
**Event:** DevFest Mbarara 2025  
**Format:** 45-minute Workshop  
**Date:** November 15, 2025

---

## 📄 SLIDE 1: TITLE SLIDE

**TITLE:**
# Using Google Sheets to Power Your Flutter App

**SUBTITLE:**
Your data, your app, all on Google Sheets.

**SPEAKER INFO:**
- Busingye Anthony
- DevFest Mbarara 2025
- November 15, 2025

**VISUAL:** DevFest Mbarara logo/branding

---

## 📄 SLIDE 2: THE REAL-WORLD PROBLEM

**TITLE:**
# The Real-World Problem: Beverage Logistics

**CONTENT:**

### Challenge: Manual Record-Keeping
❌ Errors in calculations  
❌ Delays in sales reporting  
❌ Friction between drivers and management  
❌ No real-time visibility  

### Goal: Build a Real-Time Solution
1. **Loading** - Track cartons loaded per driver/vehicle
2. **Returns** - Track cartons returned per driver/vehicle  
3. **Sales Calculation** - Automatic: Sales = Loaded - Returned

**DIAGRAM:**
```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   LOADING   │ ───> │   RETURNS   │ ───> │    SALES    │
│             │      │             │      │             │
│ Driver A    │      │ Driver A    │      │ Driver A    │
│ Vehicle 123 │      │ Vehicle 123 │      │ Sales: 50   │
│ Cartons: 100│      │ Cartons: 50 │      │             │
└─────────────┘      └─────────────┘      └─────────────┘
```

**SPEAKER NOTE:** Real problem solved for local beverage business in Uganda.

---

## 📄 SLIDE 3: WHY GOOGLE SHEETS?

**TITLE:**
# Why Google Sheets? (The Low-Code Backend)

**CONTENT:**

✅ **Zero Server Costs**  
   Completely bypass complex server infrastructure

✅ **Familiarity**  
   Data instantly viewable/editable by managers in spreadsheet

✅ **Real-Time Data**  
   Perfect for dynamic inventory or logistics tracking

✅ **No Database Setup**  
   No need for SQL, MongoDB, or Firebase setup

✅ **Easy Collaboration**  
   Multiple users can view/edit data simultaneously

**DIAGRAM:**
```
Traditional Backend          vs          Google Sheets
┌──────────────┐                        ┌──────────────┐
│   Database   │                        │ Google Sheet │
│   Server     │                        │   (Cloud)    │
│   Setup      │                        │   (Free)     │
│   $ Cost     │                        │   (Simple)   │
└──────────────┘                        └──────────────┘
     Complex                                  Simple
```

**SPEAKER NOTE:** This is the "beyond documentation" insight - Google Sheets is a legitimate backend!

---

## 📄 SLIDE 4: PREREQUISITES

**TITLE:**
# Prerequisites

**CONTENT:**

**Required Tools:**
- Flutter SDK (2.0+)
- Google Account
- Google Cloud Console access
- IDE (VS Code / Android Studio)

**Basic Knowledge:**
- Dart/Flutter basics
- REST APIs concept
- JSON format

**SPEAKER NOTE:** Ask attendees to open Flutter if they want to follow along.

---

## 📄 SLIDE 5: STEP 1 - STRUCTURING OUR BACKEND

**TITLE:**
# Step 1: Structuring Our Backend (Google Sheet)

**CONTENT:**

**Required Columns:**

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

**DIAGRAM:**
```
Google Sheet Structure:
┌─────────────────────────────────────────┐
│  LOADINGS Sheet                         │
├──────┬──────────┬──────────┬───────────┤
│ Date │ Driver   │ Vehicle  │ Products  │
├──────┼──────────┼──────────┼───────────┤
│ ...  │ Driver A │ UBA 123  │ 100       │
│ ...  │ Driver B │ UBA 456  │ 150       │
└──────┴──────────┴──────────┴───────────┘
```

**SPEAKER NOTE:** Show your actual Google Sheet to the audience.

---

## 📄 SLIDE 6: STEP 2 - SECURING THE CONNECTION

**TITLE:**
# Step 2: Securing the Connection

**CONTENT:**

### Authentication: Service Account

**Why Service Account?**
- ✅ Most reliable for automated systems
- ✅ No user sign-in required
- ✅ Perfect for backend operations
- ✅ No token expiration issues

**Steps:**
1. Go to Google Cloud Console
2. Create a new project
3. Enable Google Sheets API
4. Create Service Account
5. Generate JSON credentials file
6. **Share Google Sheet with service account email**

**DIAGRAM:**
```
Setup Flow:
┌──────────────────┐
│ Google Cloud     │
│ Console          │
└────────┬─────────┘
         │
         │ 1. Create Service Account
         ▼
┌──────────────────┐
│ Download JSON    │
│ Credentials      │
└────────┬─────────┘
         │
         │ 2. Extract credentials
         ▼
┌──────────────────┐
│ Flutter App      │
│ (Service Account)│
└────────┬─────────┘
         │
         │ 3. Share Sheet
         ▼
┌──────────────────┐
│ Google Sheet     │
│ (Shared Access)  │
└──────────────────┘
```

**SPEAKER NOTE:** Live demo: Show Google Cloud Console setup.

---

## 📄 SLIDE 7: STEP 3 - FLUTTER INTEGRATION

**TITLE:**
# Step 3: Flutter Integration

**CONTENT:**

**Packages (pubspec.yaml):**
```yaml
dependencies:
  googleapis: ^12.0.0
  googleapis_auth: ^1.4.1
  http: ^1.1.0
  flutter_dotenv: ^5.1.0
```

**Project Structure:**
```
lib/
  ├── services/
  │   └── google_sheets_service.dart  ← Core service
  ├── models/
  │   └── loading_return.dart         ← Data model
  └── screens/
      ├── loading_screen.dart         ← UI
      ├── returns_screen.dart
      └── sales_screen.dart
```

**SPEAKER NOTE:** Show Flutter project structure.

---

## 📄 SLIDE 8: THE KEY CODE - SERVICE ACCOUNT AUTH

**TITLE:**
# The Key Code: Service Account Authentication

**CONTENT:**

**THIS IS THE WORKING CODE:**

```dart
Future<void> _initialize() async {
  // 1. Create Service Account credentials
  final credentials = ServiceAccountCredentials.fromJson({
    'type': 'service_account',
    'private_key': _privateKey,
    'client_email': _clientEmail,
    'token_uri': 'https://oauth2.googleapis.com/token',
  });

  // 2. Authenticate using Service Account
  _client = await clientViaServiceAccount(
    credentials,
    [SheetsApi.spreadsheetsScope],
    baseClient: http.Client(),
  );

  // 3. Create Sheets API instance
  _sheetsApi = SheetsApi(_client!);
}
```

**Why This Works:**
- ✅ No user interaction needed
- ✅ Automatic token refresh
- ✅ Works on all platforms
- ✅ Perfect for automated systems

**SPEAKER NOTE:** This is the critical code that makes it work!

---

## 📄 SLIDE 9: THE R IN CRUD - READING RECORDS

**TITLE:**
# The R in CRUD: Reading Records

**CONTENT:**

**Code:**
```dart
Future<List<List<dynamic>>> getSheetData(String range) async {
  final response = await (await _api).spreadsheets.values.get(
    _spreadsheetId,
    range, // e.g., 'LOADINGS!A2:Z'
  );
  return response.values ?? [];
}
```

**Usage:**
```dart
// Load all loading records
final data = await _googleSheetsService.getSheetData('LOADINGS!A2:Z');

// Display in ListView
ListView.builder(
  itemCount: data.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(data[index][1]), // Driver name
      subtitle: Text(data[index][2]), // Vehicle
    );
  },
)
```

**DIAGRAM:**
```
Flutter App                    Google Sheets API              Google Sheet
┌──────────┐                  ┌──────────────┐              ┌──────────┐
│          │                  │              │              │          │
│  READ    │ ──────────────>  │  GET Request │ ──────────> │  Data    │
│ Request  │                  │              │              │          │
│          │ <──────────────  │  Response    │ <────────── │          │
│  Data    │                  │              │              │          │
└──────────┘                  └──────────────┘              └──────────┘
```

**SPEAKER NOTE:** Live-code this function and show it working.

---

## 📄 SLIDE 10: THE C IN CRUD - CREATING RECORDS

**TITLE:**
# The C in CRUD: Creating Records

**CONTENT:**

**Code:**
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

**Usage:**
```dart
// Create new loading record
final row = [
  '2024-11-15',        // Date
  'John Doe',          // Driver
  'UBA 123',           // Vehicle
  '100',               // Product quantity
];

await _googleSheetsService.appendRow('LOADINGS!A:Z', row);
```

**DIAGRAM:**
```
User Input              Flutter App              Google Sheets
┌──────────┐           ┌──────────┐             ┌──────────┐
│          │           │          │             │          │
│  Form    │ ────────> │  CREATE  │ ──────────> │  New Row │
│  Data    │           │  Request │             │  Added   │
│          │           │          │             │          │
└──────────┘           └──────────┘             └──────────┘
```

**SPEAKER NOTE:** Live demo: Add a record and show it appearing in real-time in Google Sheet!

---

## 📄 SLIDE 11: THE BUSINESS LOGIC - SALES CALCULATION

**TITLE:**
# The Business Logic: Sales Calculation

**CONTENT:**

**Formula:**
```
Sales = Total Cartons Loaded - Total Cartons Returned
```

**Implementation:**
```dart
Map<String, int> calculateSales(
  List<LoadingReturn> loadings,
  List<LoadingReturn> returns,
) {
  final sales = <String, Map<String, int>>{};

  // Sum all loadings by driver/product
  for (final loading in loadings) {
    final key = '${loading.driverName}_${loading.vehicleNumber}';
    loading.productQuantities.forEach((product, quantity) {
      sales[key]![product] = (sales[key]![product] ?? 0) + quantity;
    });
  }

  // Subtract returns
  for (final returnRecord in returns) {
    final key = '${returnRecord.driverName}_${returnRecord.vehicleNumber}';
    returnRecord.productQuantities.forEach((product, quantity) {
      sales[key]![product] = (sales[key]![product] ?? 0) - quantity;
    });
  }

  return sales;
}
```

**DIAGRAM:**
```
Calculation Flow:
┌─────────────┐
│  LOADINGS   │ ──┐
│  Sheet      │   │
└─────────────┘   │
                  │
┌─────────────┐   │    ┌──────────────┐    ┌─────────────┐
│  RETURNS    │ ──┼──> │  Calculate   │──> │    SALES    │
│  Sheet      │   │    │  Sales =     │    │  Results    │
└─────────────┘   │    │  Load - Ret  │    └─────────────┘
                  │    └──────────────┘
                  │
                  └──> Read both sheets
```

**SPEAKER NOTE:** Walk through the calculation logic step by step.

---

## 📄 SLIDE 12: LIVE DEMO - THE COMPLETE APP

**TITLE:**
# Live Demo: The Complete App

**CONTENT:**

**Features:**
✅ **Loading Screen** - Record products loaded  
✅ **Returns Screen** - Record products returned  
✅ **Sales Screen** - View calculated sales
   - By Driver
   - By Product
   - Daily/Weekly/Monthly reports

**App Flow:**
```
┌──────────────┐
│  Main Menu   │
└──────┬───────┘
       │
       ├──> ┌──────────────┐
       │    │   Loading    │ ──> Google Sheet (LOADINGS)
       │    │   Screen     │
       │    └──────────────┘
       │
       ├──> ┌──────────────┐
       │    │   Returns    │ ──> Google Sheet (RETURNS)
       │    │   Screen     │
       │    └──────────────┘
       │
       └──> ┌──────────────┐
            │    Sales     │ ──> Calculated from both sheets
            │   Screen     │
            └──────────────┘
```

**SPEAKER NOTE:** Show the complete app running. Switch between app and Google Sheet to show real-time sync!

---

## 📄 SLIDE 13: SERVICE ACCOUNT vs OAUTH2

**TITLE:**
# Service Account vs OAuth2: Why One Works, One Doesn't

**CONTENT:**

| Feature | Service Account ✅ | OAuth2 ❌ |
|---------|-------------------|-----------|
| **User Interaction** | None required | Required (consent) |
| **Token Expiration** | Auto-refreshed | Expires (1 hour) |
| **Setup** | Simple | Complex |
| **Background Ops** | Works | Fails |
| **Mobile/Web** | Works seamlessly | Platform issues |

**DIAGRAM:**
```
Service Account Flow:          OAuth2 Flow:
┌──────────┐                  ┌──────────┐
│   App    │                  │   App    │
└────┬─────┘                  └────┬─────┘
     │                             │
     │ Direct Auth                 │ User Login Required
     ▼                             ▼
┌──────────┐                  ┌──────────┐
│  Sheets  │                  │  User    │
│  API     │                  │  Consent │
└──────────┘                  └────┬─────┘
     │                             │
     │ Works!                      │ Token Expires
     ▼                             ▼
┌──────────┐                  ┌──────────┐
│  Sheet   │                  │  Fails!  │
└──────────┘                  └──────────┘
```

**SPEAKER NOTE:** This is a key "beyond documentation" insight!

---

## 📄 SLIDE 14: KEY SECURITY & SCALING INSIGHTS

**TITLE:**
# Key Security & Scaling Insights

**CONTENT:**

### 1. Data Validation
✅ Validate in Flutter before sending  
✅ Use proper data types (int, String, DateTime)  
✅ Implement form validation  

### 2. Key Protection
❌ Never hardcode credentials  
✅ Use environment variables (.env file)  
✅ For web: Use Firebase Functions as proxy  
✅ For mobile: Use Flutter Secure Storage  

### 3. Performance Optimization
✅ Only fetch specific ranges (not entire sheet)  
✅ Implement caching for frequently accessed data  
✅ Use batch operations when possible  
✅ Add retry logic with exponential backoff  

### 4. Scaling Considerations
⚠️ Google Sheets API rate limits: 100 requests/100 seconds/user  
⚠️ Best for < 10,000 rows  
⚠️ Consider Firebase/MongoDB for larger datasets  

**SPEAKER NOTE:** Share real problems you encountered and solutions.

---

## 📄 SLIDE 15: COMMON PITFALLS & SOLUTIONS

**TITLE:**
# Common Pitfalls & Solutions

**CONTENT:**

**Problem 1: "Permission Denied"**  
✅ Solution: Share Google Sheet with service account email

**Problem 2: "Invalid Range"**  
✅ Solution: Validate sheet names exist before operations

**Problem 3: "Rate Limiting"**  
✅ Solution: Implement retry logic with delays

**Problem 4: "Date Format Issues"**  
✅ Solution: Standardize date format (YYYY-MM-DD)

**Problem 5: "Empty Cells"**  
✅ Solution: Always check for null/empty values

**DIAGRAM:**
```
Common Errors:
┌─────────────────────┐
│  Permission Denied  │ ──> Share sheet with service account
├─────────────────────┤
│  Invalid Range      │ ──> Check sheet name exists
├─────────────────────┤
│  Rate Limiting      │ ──> Add retry logic
├─────────────────────┤
│  Date Format        │ ──> Use YYYY-MM-DD
├─────────────────────┤
│  Empty Cells        │ ──> Check for null values
└─────────────────────┘
```

**SPEAKER NOTE:** Share actual errors you encountered and how you fixed them.

---

## 📄 SLIDE 16: WHEN TO USE THIS APPROACH

**TITLE:**
# When to Use Google Sheets as Backend

**CONTENT:**

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
```
Start: Google Sheets
  │
  │ (When you outgrow it)
  ▼
Migrate: Firebase / MongoDB
  │
  │ (Keep same Flutter structure)
  ▼
Same App, Different Backend
```

**SPEAKER NOTE:** Be honest about limitations. Help attendees make informed decisions.

---

## 📄 SLIDE 17: ALTERNATIVE USE CASES

**TITLE:**
# Other Real-World Applications

**CONTENT:**

**Use Cases:**
- 📋 **Event Registration** - Track attendees and check-ins
- 📦 **Inventory Management** - Stock levels and alerts
- 📊 **Survey/Feedback Collection** - Forms data collection
- 👥 **Team Collaboration** - Shared task lists
- 📝 **Content Management** - Dynamic app content
- 📈 **Analytics Dashboard** - Business metrics tracking
- 💼 **Lead Management** - CRM for small businesses

**DIAGRAM:**
```
Google Sheets as Backend
        │
        ├──> Event Registration
        ├──> Inventory Tracking
        ├──> Survey Collection
        ├──> Task Management
        ├──> Content CMS
        ├──> Analytics Dashboard
        └──> Lead CRM
```

**SPEAKER NOTE:** Encourage attendees to think of their own use cases.

---

## 📄 SLIDE 18: RESOURCES & NEXT STEPS

**TITLE:**
# Resources & Next Steps

**CONTENT:**

**Documentation:**
- Google Sheets API: https://developers.google.com/sheets/api
- Flutter Packages: https://pub.dev/packages/googleapis
- Service Account Setup: (Your guide)

**Code Repository:**
- GitHub: [Your repo link]
- Demo Project: Available for download

**Next Steps:**
1. Set up your Google Cloud project
2. Create a test Sheet
3. Build your first CRUD operation
4. Share your project with the community!

**SPEAKER NOTE:** Provide links. Offer to share slides/code after event.

---

## 📄 SLIDE 19: THANK YOU & CONNECT

**TITLE:**
# Thank You!

**CONTENT:**

**Speaker:** Busingye Anthony

**Connect:**
- Email: [Your email]
- X/Twitter: [Your handle]
- LinkedIn: [Your profile]

**Hashtags:**
#DevFestMbarara2025
#FlutterDev
#GoogleSheets
#LowCodeBackend

**Q&A Session**

**SPEAKER NOTE:** Thank organizers and attendees. Open floor for questions.

---

## 📊 PRESENTATION TIMING GUIDE

**Total: 45 minutes**

- **Introduction (5 min):** Slides 1-4
- **Setup & Backend (10 min):** Slides 5-7
- **Live Coding (20 min):** Slides 8-11
- **Demo & Insights (8 min):** Slides 12-16
- **Q&A (2 min):** Slides 17-19

---

## 🎨 VISUAL ELEMENTS TO CREATE

1. **Slide 2:** Flow diagram (Loading → Returns → Sales)
2. **Slide 3:** Comparison diagram (Traditional vs Google Sheets)
3. **Slide 5:** Google Sheet structure table
4. **Slide 6:** Setup flow diagram
5. **Slide 9:** API request/response flow
6. **Slide 10:** Data creation flow
7. **Slide 11:** Sales calculation flow
8. **Slide 12:** App architecture diagram
9. **Slide 13:** Service Account vs OAuth2 comparison
10. **Slide 15:** Error solutions diagram
11. **Slide 16:** Migration path diagram
12. **Slide 17:** Use cases diagram

---

## ✅ FINAL CHECKLIST

Before presentation:
- [ ] All slides created in 16:9 format
- [ ] Code snippets tested
- [ ] Demo app ready and tested
- [ ] Backup demo/video prepared
- [ ] Credentials secured (not in slides)
- [ ] Internet connection tested
- [ ] Slides exported to PDF backup
- [ ] Speaker notes reviewed
- [ ] Time yourself (45 minutes)

**Good luck with your presentation! 🚀**

