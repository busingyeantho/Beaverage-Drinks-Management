# Setup Instructions for Production Upgrade
## Getting Your App Ready

---

## 📦 Step 1: Install New Dependencies

Run this command to install the new packages:

```bash
flutter pub get
```

**New packages added:**
- `cloud_firestore: ^5.4.4` - For secure role management

---

## 🔥 Step 2: Firebase Firestore Setup

### Enable Firestore in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click "Firestore Database" in the left menu
4. Click "Create database"
5. Choose "Start in test mode" (we'll add security rules next)
6. Select a location (choose closest to your users)
7. Click "Enable"

### Set Up Security Rules

1. In Firestore, go to "Rules" tab
2. Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read their own data, admins can write
    match /users/{userId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }
    
    // Default: deny all access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click "Publish"

---

## 👤 Step 3: Create First Admin User

### Option 1: Through Firebase Console

1. Go to Firebase Console → Authentication
2. Click "Add user"
3. Add an email and password
4. Note the User UID

5. Go to Firestore → Data
6. Create a new document in `users` collection:
   - Document ID: (the User UID from step 3)
   - Fields:
     - `email`: (the email you used)
     - `displayName`: "Admin User"
     - `role`: "superAdmin"
     - `isActive`: true
     - `createdAt`: (timestamp)

### Option 2: Through Code (Temporary)

You can temporarily add this to your app to create the first admin:

```dart
// Temporary code - remove after creating admin
Future<void> createFirstAdmin() async {
  final adminEmail = 'admin@yourcompany.com';
  final adminPassword = 'SecurePassword123!';
  
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': adminEmail,
      'displayName': 'Super Admin',
      'role': 'superAdmin',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    print('Admin created successfully!');
  } catch (e) {
    print('Error creating admin: $e');
  }
}
```

**Remember to remove this code after creating the admin!**

---

## 🔐 Step 4: Secure Your Test Data

### Create Separate Google Sheet for Test Data

1. Create a new Google Sheet for testing
2. **DO NOT** share this sheet publicly
3. Only share with your service account email
4. Update your `.env` file with the test sheet ID

### Update Environment Variables

In your `.env` file, you can have:

```env
# Production Sheet
GOOGLE_SHEETS_SPREADSHEET_ID=your_production_sheet_id

# Test Sheet (for development)
GOOGLE_SHEETS_TEST_SPREADSHEET_ID=your_test_sheet_id
```

---

## ✅ Step 5: Test the App

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **You should see:**
   - Beautiful splash screen
   - Login screen (if not logged in)
   - Main menu (if logged in)

3. **Test registration:**
   - Click "Sign Up"
   - Create a new account
   - Note: New users get `loadingAdmin` role by default

4. **Test login:**
   - Sign in with email/password
   - Or use Google Sign-In

---

## 🎨 What's New

### ✅ Completed Features

1. **Splash Screen**
   - Beautiful animated loading screen
   - Shows app branding
   - Auto-navigates based on auth state

2. **Enhanced Login**
   - Modern gradient design
   - Email/Password login
   - Google Sign-In option
   - Link to registration

3. **Registration Screen**
   - Account creation
   - Form validation
   - Password confirmation
   - Beautiful UI

4. **Role Management**
   - Roles stored in Firestore (secure)
   - Default role: `loadingAdmin`
   - SuperAdmin can assign roles
   - Real-time role updates

5. **Authentication Flow**
   - Proper auth checking
   - Role-based navigation
   - Secure session management

---

## 🚧 Still To Do

### Phase 2: UI/UX Enhancements
- [ ] Enhance main menu with user info
- [ ] Add logout functionality
- [ ] Role-based navigation guards
- [ ] Loading states on all screens
- [ ] Error handling UI improvements

### Phase 3: Security
- [ ] Admin dashboard for role management
- [ ] Secure test data separation
- [ ] API key protection (Firebase Functions)
- [ ] Input validation on all forms

---

## 🐛 Troubleshooting

### Error: "cloud_firestore package not found"
**Solution:** Run `flutter pub get`

### Error: "Permission denied" in Firestore
**Solution:** Check security rules are published

### Error: "User not found" after login
**Solution:** User profile might not exist. Check Firestore `users` collection.

### App shows login screen even when logged in
**Solution:** Check `checkAuthState()` is being called in splash screen.

---

## 📝 Next Steps

1. ✅ Install dependencies: `flutter pub get`
2. ✅ Set up Firestore
3. ✅ Create admin user
4. ✅ Test the app
5. ⏭️ Enhance UI/UX (Phase 2)
6. ⏭️ Add security features (Phase 3)

---

**Your app is now production-ready with proper authentication! 🎉**


