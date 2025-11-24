# Step-by-Step: Create Super Admin Account

## ✅ You've Done: Created Authentication Account
- Email: `manager@gmail.com`
- Password: Set ✓

## 📋 Next Steps: Set Role in Firestore

### **Step 1: Get Your User ID (UID)**

1. **Go to Firebase Console:**
   - Visit: [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Select your project: `johnpomb-b85d0` (or your project name)

2. **Open Authentication:**
   - Click **"Authentication"** in the left menu
   - Click the **"Users"** tab (should be selected by default)

3. **Find Your User:**
   - Look for `manager@gmail.com` in the list
   - You'll see a column with **"User UID"** - this is a long string like: `abc123xyz456...`
   - **COPY THIS UID** (you'll need it in Step 2)

---

### **Step 2: Create User Document in Firestore**

1. **Go to Firestore Database:**
   - Click **"Firestore Database"** in the left menu
   - Click the **"Data"** tab at the top

2. **Create the `users` Collection (if it doesn't exist):**
   - If you see "No collections yet" or empty:
     - Click **"Start collection"** button
     - Collection ID: type `users` (lowercase, exactly as shown)
     - Click **"Next"**

3. **Add Your User Document:**
   - **Document ID:** Paste the **User UID** you copied from Step 1
     - ⚠️ **IMPORTANT:** Use the exact UID from Authentication, NOT a random ID
   - Click **"Next"**

4. **Add Fields:**
   - Click **"Add field"** for each field below:

   **Field 1:**
   - Field name: `email`
   - Field type: **string**
   - Field value: `manager@gmail.com`
   - Click **"Save"**

   **Field 2:**
   - Field name: `displayName`
   - Field type: **string**
   - Field value: `Manager` (or your preferred name)
   - Click **"Save"**

   **Field 3:**
   - Field name: `role`
   - Field type: **string**
   - Field value: `superAdmin` (⚠️ **EXACTLY** like this - case sensitive!)
   - Click **"Save"**

   **Field 4:**
   - Field name: `isActive`
   - Field type: **boolean**
   - Field value: `true` (toggle it ON)
   - Click **"Save"**

   **Field 5:**
   - Field name: `createdAt`
   - Field type: **timestamp**
   - Click the **"timestamp"** button (it will set current time)
   - Click **"Save"**

5. **Final Step:**
   - Click **"Save"** button at the bottom
   - You should see your document in the `users` collection

---

### **Step 3: Verify It Worked**

1. **Check the Document:**
   - In Firestore, you should see:
     - Collection: `users`
     - Document ID: (your User UID)
     - Fields:
       - `email`: "manager@gmail.com"
       - `displayName`: "Manager"
       - `role`: "superAdmin" ← **This is the key one!**
       - `isActive`: true
       - `createdAt`: (timestamp)

2. **Test in Your App:**
   - Open your Flutter app
   - **Log out** if you're logged in
   - **Log in** with:
     - Email: `manager@gmail.com`
     - Password: (your password)
   - You should now see:
     - Dashboard with your name
     - Role badge showing "Super Admin"
     - "User Management" option in Administration section

---

## 🎯 Visual Guide (What You Should See)

### **In Authentication:**
```
Users Tab:
┌─────────────────────────────────────────┐
│ Email              │ User UID           │
├─────────────────────────────────────────┤
│ manager@gmail.com  │ abc123xyz456...   │ ← COPY THIS
└─────────────────────────────────────────┘
```

### **In Firestore:**
```
users Collection:
┌──────────────────────────────────────────────┐
│ Document ID: abc123xyz456...                │
│                                              │
│ email: "manager@gmail.com"                  │
│ displayName: "Manager"                       │
│ role: "superAdmin"  ← MUST BE EXACTLY THIS  │
│ isActive: true                              │
│ createdAt: 2024-01-15 10:30:00             │
└──────────────────────────────────────────────┘
```

---

## ⚠️ Common Mistakes to Avoid

1. **Wrong Document ID:**
   - ❌ DON'T: Use a random ID or email
   - ✅ DO: Use the exact User UID from Authentication

2. **Wrong Role Value:**
   - ❌ DON'T: "SuperAdmin", "super_admin", "Super Admin"
   - ✅ DO: "superAdmin" (exactly as shown - lowercase 's', uppercase 'A')

3. **Wrong Collection Name:**
   - ❌ DON'T: "Users", "user", "USER"
   - ✅ DO: "users" (lowercase, plural)

4. **Missing Fields:**
   - Make sure all 5 fields are added
   - Especially `role` and `isActive`

---

## 🆘 Troubleshooting

### **"I can't find Authentication in Firebase Console"**
- Make sure you're in the correct project
- Authentication should be in the left sidebar
- If not visible, click the hamburger menu (☰) to expand

### **"I can't find my user in Authentication"**
- Make sure you created the account in Firebase Authentication
- Check if you're in the right project
- Try refreshing the page

### **"I can't create a collection in Firestore"**
- Make sure you're in the "Data" tab
- Click "Start collection" button
- If button is grayed out, check if you have permissions

### **"I logged in but still see 'Pending Approval'"**
- Check Firestore: Is the `role` field exactly `"superAdmin"`? (case-sensitive)
- Check Firestore: Is the Document ID exactly your User UID?
- Try logging out and logging back in
- Check browser console (F12) for errors

### **"I don't see 'User Management' in the app"**
- Your role might not be set correctly
- Double-check the `role` field in Firestore is `"superAdmin"`
- Make sure you logged out and logged back in after creating the document

---

## ✅ Quick Checklist

Before testing in the app, verify:

- [ ] User exists in Firebase Authentication (`manager@gmail.com`)
- [ ] User UID copied from Authentication
- [ ] `users` collection exists in Firestore
- [ ] Document created with User UID as Document ID
- [ ] `email` field = "manager@gmail.com"
- [ ] `displayName` field = "Manager" (or your name)
- [ ] `role` field = "superAdmin" (exactly, case-sensitive)
- [ ] `isActive` field = true
- [ ] `createdAt` field = timestamp
- [ ] Document saved successfully

---

## 🎉 Success!

Once you complete these steps:
1. Log out of your app
2. Log in with `manager@gmail.com`
3. You should see "Super Admin" badge
4. You should see "User Management" option
5. You can now approve other users!

---

**Need help?** If you're stuck at any step, let me know which step and what you're seeing!

