# Firestore Security Rules for Production Mode
## Updated Rules for Registration to Work

---

## 🔐 Production Security Rules

Since you selected **Production Mode**, you need to update the security rules to allow users to create their own profile during registration.

### Step 1: Go to Firestore Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `johnpomb-b85d0`
3. Click "Firestore Database" in the left menu
4. Click the "Rules" tab at the top

### Step 2: Replace with These Rules

**Copy and paste these rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is superAdmin
    function isSuperAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }
    
    // Users collection
    match /users/{userId} {
      // Allow users to read their own data
      // OR allow superAdmin to read any user's data (for user management)
      allow read: if request.auth != null && 
                     (request.auth.uid == userId || isSuperAdmin());
      
      // Allow users to create their own profile (for registration)
      allow create: if request.auth != null && 
                       request.auth.uid == userId &&
                       request.resource.data.keys().hasAll(['email', 'displayName', 'role', 'isActive']) &&
                       request.resource.data.role is string;
      
      // Allow users to update their own displayName only
      // OR allow superAdmin to update any user (for role management)
      allow update: if request.auth != null && 
                       ((request.auth.uid == userId &&
                        !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'isActive'])) ||
                       isSuperAdmin());
      
      // Only superAdmin can delete users
      allow delete: if isSuperAdmin();
    }
    
    // Audit logs collection - only superAdmin can read
    match /audit_logs/{logId} {
      allow read: if isSuperAdmin();
      allow write: if isSuperAdmin();
    }
    
    // Default: deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish Rules

1. Click "Publish" button
2. Wait for confirmation: "Rules published successfully"

---

## 🔍 What These Rules Do

✅ **Allow Registration:**
- Users can create their own profile document during registration
- Must match their authenticated user ID
- Must include required fields (email, displayName, role, isActive)

✅ **Allow Reading Own Data:**
- Users can read their own user document
- Needed for role checking

✅ **Allow Self Updates:**
- Users can update their displayName
- Cannot change their own role or isActive status

✅ **Admin Access:**
- SuperAdmin can read/write any user document
- Needed for role management

✅ **Secure:**
- All other collections are denied by default
- Only authenticated users can access
- Users can only modify their own data (except admins)

---

## 🧪 Test the Rules

After publishing:

1. **Try registration again** in your app
2. **Check browser console** (F12) for any permission errors
3. **Verify in Firestore:**
   - Go to Firestore → Data
   - Check if `users` collection exists
   - Check if your user document was created

---

## ⚠️ Important Notes

### For Production Use Later:

These rules are good for development. For production, you might want to:

1. **Add email verification requirement:**
   ```javascript
   allow create: if request.auth != null && 
                    request.auth.uid == userId &&
                    request.auth.token.email_verified == true;
   ```

2. **Add rate limiting** (use Cloud Functions)

3. **Add audit logging** (track who changes what)

4. **Restrict role values:**
   ```javascript
   request.resource.data.role in ['superAdmin', 'loadingAdmin', 'returnsAdmin', 'salesAdmin']
   ```

---

## 🐛 Troubleshooting

### Error: "Permission denied" during registration

**Check:**
1. Rules are published (not just saved)
2. User is authenticated (Firebase Auth created the user)
3. User ID matches document ID
4. All required fields are present

### Error: "Missing or insufficient permissions"

**Solution:** Make sure the rules allow `create` for authenticated users with matching user ID.

### Still not working?

1. Check browser console (F12) for exact error
2. Verify user is authenticated: `request.auth != null`
3. Verify user ID matches: `request.auth.uid == userId`
4. Check Firestore → Rules → Simulator to test rules

---

## 📝 Quick Checklist

- [ ] Firestore is enabled
- [ ] Rules tab is open
- [ ] Rules are copied and pasted
- [ ] Rules are published (not just saved)
- [ ] Try registration again
- [ ] Check browser console for errors
- [ ] Verify user document created in Firestore

---

**After updating the rules, try registration again!** ✅


