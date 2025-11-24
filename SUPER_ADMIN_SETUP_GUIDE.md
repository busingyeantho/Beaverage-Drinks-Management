# Super Admin Setup Guide

## 🎯 How to Create Your First Super Admin

Since new users now start with a "pending" role (requiring approval), you need to manually create the first Super Admin account.

### **Option 1: Create via Firebase Console (Recommended)**

1. **Go to Firebase Console:**
   - Visit [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Select your project: `johnpomb-b85d0`

2. **Go to Firestore Database:**
   - Click "Firestore Database" in the left menu
   - Click the "Data" tab

3. **Create the Super Admin User Document:**
   - If the `users` collection doesn't exist, create it
   - Click "Add document"
   - **Document ID:** Use your Firebase Auth User ID
     - To find your User ID:
       - Go to Firebase Console → Authentication → Users
       - Find your email and copy the User ID (UID)
   - **Fields:**
     ```
     email: "your-email@example.com"
     displayName: "Your Name"
     role: "superAdmin"
     isActive: true
     createdAt: [timestamp - click "timestamp" button]
     ```
   - Click "Save"

4. **Verify:**
   - Log out and log back in to your app
   - You should now see "Super Admin" in your dashboard
   - You should see "User Management" in the Administration section

---

### **Option 2: Register First, Then Update in Firebase**

1. **Register your account in the app:**
   - Use the registration screen
   - You'll get a "pending" role

2. **Go to Firebase Console:**
   - Firestore Database → Data
   - Find your user document in the `users` collection
   - Click on it to edit

3. **Change the role:**
   - Change `role` from `"pending"` to `"superAdmin"`
   - Click "Update"

4. **Verify:**
   - Log out and log back in
   - You should now be Super Admin

---

## 📋 Real-World Admin Assignment Process

### **In Big Companies:**

1. **Initial Setup:**
   - System owner/CTO creates the first Super Admin manually
   - This is done BEFORE the app goes live
   - Usually done via database or admin console

2. **New User Registration:**
   - User registers → Gets "pending" role
   - Cannot access any features
   - Super Admin gets notified (or checks User Management screen)

3. **Super Admin Reviews:**
   - Super Admin checks:
     - Is this a legitimate employee?
     - What department do they work in?
     - What's their job title?
     - What access do they need?

4. **Role Assignment:**
   - Super Admin assigns appropriate role:
     - **Loading Admin:** Warehouse staff, loading supervisors
     - **Returns Admin:** Operations staff, returns managers
     - **Sales Admin:** Sales team, sales managers
     - **Super Admin:** Only for IT/Management (rare)

5. **User Gets Access:**
   - User can now log in and access their assigned features

---

## 🔐 Security Best Practices

1. **Limit Super Admins:**
   - Only 1-2 Super Admins in a company
   - Usually: IT Manager, CTO, or Company Owner

2. **Regular Audits:**
   - Review user roles quarterly
   - Remove access for former employees
   - Check audit logs for suspicious activity

3. **Documentation:**
   - Keep a record of who has what role
   - Document why each role was assigned
   - Maintain an approval process

---

## ✅ Quick Checklist

- [ ] First Super Admin created in Firestore
- [ ] Super Admin can log in and see dashboard
- [ ] User Management screen is accessible
- [ ] New users register with "pending" role
- [ ] Super Admin can approve and assign roles
- [ ] Audit logs are being created (check Firestore `audit_logs` collection)

---

## 🆘 Troubleshooting

### **"I can't see User Management"**
- Check your role in Firestore: `users/{yourUserId}`
- Role should be `"superAdmin"` (case-sensitive)

### **"New users can't access anything"**
- This is correct! They have "pending" role
- Super Admin must approve them first

### **"I registered but I'm stuck"**
- Your role is "pending"
- Ask your Super Admin to approve you
- Or manually update your role in Firestore to "superAdmin"

---

**Remember:** In production, the first Super Admin is usually created manually by the system owner before the app goes live. This ensures proper security and control from day one.

