# How to Handle the Service Account JSON File
## ✅ Recommended Approach vs ❌ What NOT to Do

---

## ❌ DO NOT: Drop JSON File in Project

**Don't do this:**
```
your_project/
  ├── lib/
  ├── assets/
  ├── service-account.json  ← DON'T PUT IT HERE!
  └── pubspec.yaml
```

**Why NOT:**
- ❌ Security risk if committed to Git
- ❌ Harder to manage in Flutter
- ❌ Not the standard Flutter approach
- ❌ More complex code to read JSON file

---

## ✅ DO: Extract Values to .env File

**This is the correct approach:**

### Step 1: Open the JSON File

Open the downloaded JSON file (e.g., `woven-howl-349112-fd5aa60f8d79.json`)

It looks like this:
```json
{
  "type": "service_account",
  "project_id": "woven-howl-349112",
  "private_key_id": "fd5aa60f8d79",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n",
  "client_email": "your-service@woven-howl-349112.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token"
}
```

### Step 2: Extract These 3 Values

You only need these 3 values:

1. **`client_email`** - The service account email
2. **`private_key`** - The private key (keep the entire thing including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)
3. **Spreadsheet ID** - This is NOT in the JSON, you get it from your Google Sheet URL

### Step 3: Create .env File in Project Root

**Location:** `your_project/.env` (same level as `pubspec.yaml`)

```
your_project/
  ├── lib/
  ├── .env          ← CREATE THIS FILE HERE
  ├── pubspec.yaml
  └── README.md
```

### Step 4: Add Values to .env File

**Create `.env` file with this content:**

```env
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id_from_url
GOOGLE_SHEETS_CLIENT_EMAIL=your-service@woven-howl-349112.iam.gserviceaccount.com
GOOGLE_SHEETS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"
```

**Important Notes:**
- Keep the quotes around `GOOGLE_SHEETS_PRIVATE_KEY`
- Keep the `\n` characters (they represent newlines)
- Replace `your_spreadsheet_id_from_url` with your actual spreadsheet ID
- Replace the email and private key with your actual values

### Step 5: Verify .gitignore

Make sure `.env` is in your `.gitignore` file:

```gitignore
# Ignore sensitive files
.env
web/config.js
```

**Your `.gitignore` already has `.env` - perfect! ✅**

### Step 6: Store JSON File Securely (Outside Project)

**Where to keep the JSON file:**
- ✅ In a secure folder outside your project
- ✅ In a password manager
- ✅ In a secure cloud storage (encrypted)
- ✅ On your local machine (not in project folder)

**Example:**
```
D:\secure_credentials\
  └── service-account.json  ← Keep it here, not in project
```

---

## 📋 Complete Example

### Your JSON File (Keep it safe, don't put in project):
```json
{
  "type": "service_account",
  "project_id": "woven-howl-349112",
  "private_key_id": "fd5aa60f8d79",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7x...\n-----END PRIVATE KEY-----\n",
  "client_email": "beverage-service@woven-howl-349112.iam.gserviceaccount.com"
}
```

### Your .env File (In project root):
```env
GOOGLE_SHEETS_SPREADSHEET_ID=1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms
GOOGLE_SHEETS_CLIENT_EMAIL=beverage-service@woven-howl-349112.iam.gserviceaccount.com
GOOGLE_SHEETS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7x...\n-----END PRIVATE KEY-----\n"
```

### Your Code (Already set up correctly):
```dart
GoogleSheetsService()
  : _spreadsheetId = dotenv.env['GOOGLE_SHEETS_SPREADSHEET_ID'] ?? '',
    _clientEmail = dotenv.env['GOOGLE_SHEETS_CLIENT_EMAIL'] ?? '',
    _privateKey = (dotenv.env['GOOGLE_SHEETS_PRIVATE_KEY'] ?? '')
        .replaceAll(r'\n', '\n')
```

---

## 🔒 Security Best Practices

### ✅ DO:
- ✅ Extract values to `.env` file
- ✅ Add `.env` to `.gitignore`
- ✅ Keep JSON file in secure location outside project
- ✅ Never commit credentials to Git
- ✅ Use environment variables in production

### ❌ DON'T:
- ❌ Put JSON file in project folder
- ❌ Commit JSON file to Git
- ❌ Hardcode credentials in code
- ❌ Share credentials publicly
- ❌ Put credentials in version control

---

## 🎯 Quick Checklist

- [ ] JSON file downloaded from Google Cloud Console
- [ ] JSON file stored securely (outside project)
- [ ] `.env` file created in project root
- [ ] Three values extracted and added to `.env`:
  - [ ] Spreadsheet ID
  - [ ] Client Email
  - [ ] Private Key
- [ ] `.env` added to `.gitignore` ✅ (already done)
- [ ] `.env` file loaded in `main.dart`
- [ ] Test app - it works!

---

## 💡 Alternative: Reading JSON File Directly (Not Recommended)

If you really want to read the JSON file directly (not recommended), you would:

1. Put JSON in `assets/` folder
2. Add to `pubspec.yaml`:
   ```yaml
   assets:
     - assets/service-account.json
   ```
3. Read it in code:
   ```dart
   final jsonString = await rootBundle.loadString('assets/service-account.json');
   final json = jsonDecode(jsonString);
   ```

**But this is NOT recommended because:**
- ❌ Harder to manage
- ❌ Risk of committing to Git
- ❌ Not standard Flutter practice
- ❌ More complex code

**Stick with the `.env` approach! ✅**

---

## 📝 Summary

**Answer: NO, don't drop the JSON file in your project.**

**Instead:**
1. Open the JSON file
2. Extract `client_email` and `private_key`
3. Create `.env` file in project root
4. Add the values to `.env`
5. Keep JSON file safe (outside project)
6. Your code already reads from `.env` - perfect! ✅

---

**Your current setup is correct! Just create the `.env` file with the extracted values.** 🎉

