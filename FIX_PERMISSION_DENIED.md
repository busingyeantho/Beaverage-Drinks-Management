# Fix: Permission Denied Error in User Management

## 🔴 Problem
You're getting: `[cloud_firestore/permission-denied] Missing or insufficient permissions` when trying to access User Management screen.

## ✅ Solution: Update Firestore Security Rules

The current rules don't allow Super Admins to **read all users** from the collection. They only allow reading your own document.

### **Step 1: Go to Firestore Rules**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `johnpomb-b85d0`
3. Click **"Firestore Database"** in the left menu
4. Click the **"Rules"** tab at the top

### **Step 2: Replace the Rules**

**Delete all existing rules** and **copy-paste these new rules:**

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

### **Step 3: Publish Rules**

1. Click the **"Publish"** button (top right)
2. Wait for confirmation: **"Rules published successfully"**
3. Rules take effect immediately (usually within seconds)

### **Step 4: Test**

1. Go back to your Flutter app
2. Click **"Retry"** button in the User Management screen
3. Or refresh the page
4. You should now see all users listed!

---

## 🔍 What Changed?

### **Before (Old Rules):**
- ❌ Users could only read their own document
- ❌ SuperAdmin could write but not read all users
- ❌ `getAllUsers()` query failed because it needs to read all documents

### **After (New Rules):**
- ✅ Users can still read their own document
- ✅ **SuperAdmin can read ANY user document** (for User Management screen)
- ✅ SuperAdmin can update any user (for role assignment)
- ✅ SuperAdmin can delete users
- ✅ Audit logs are protected (only SuperAdmin can access)

---

## 🎯 Key Changes Explained

1. **Added `isSuperAdmin()` helper function:**
   - Checks if the current user has `role == 'superAdmin'`
   - Used throughout the rules for SuperAdmin checks

2. **Updated `allow read`:**
   - Before: `request.auth.uid == userId` (only own document)
   - After: `request.auth.uid == userId || isSuperAdmin()` (own document OR SuperAdmin can read any)

3. **Updated `allow update`:**
   - Regular users: Can only update their own `displayName`
   - SuperAdmin: Can update any user (including role changes)

4. **Added `allow delete`:**
   - Only SuperAdmin can delete users

5. **Added `audit_logs` collection rules:**
   - Only SuperAdmin can read/write audit logs

---

## ✅ Verification Checklist

After updating rules:

- [ ] Rules are published (not just saved)
- [ ] User Management screen loads without errors
- [ ] You can see all users in the list
- [ ] You can click on users to change their roles
- [ ] Role changes work successfully
- [ ] Audit logs are being created (check Firestore `audit_logs` collection)

---

## 🆘 Still Not Working?

### **"Still getting permission denied"**

1. **Check rules are published:**
   - Rules tab should show "Published" status
   - Not just "Saved" - must click "Publish"

2. **Verify your role:**
   - Go to Firestore → Data → `users` collection
   - Find your document (using your User UID)
   - Check `role` field is exactly `"superAdmin"` (case-sensitive)

3. **Clear browser cache:**
   - Hard refresh: `Ctrl + Shift + R` (Windows) or `Cmd + Shift + R` (Mac)
   - Or close and reopen the browser

4. **Check browser console:**
   - Press `F12` to open developer tools
   - Look for any error messages
   - Check Network tab for failed requests

5. **Wait a few seconds:**
   - Rules can take 10-30 seconds to propagate
   - Try again after waiting

---

## 🎉 Success!

Once the rules are updated and published:
- ✅ User Management screen will load
- ✅ You'll see all users (pending and active)
- ✅ You can approve pending users
- ✅ You can change user roles
- ✅ Everything works as expected!

---

**After updating the rules, try accessing User Management again!** 🚀

