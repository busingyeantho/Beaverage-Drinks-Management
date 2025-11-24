import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class RoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user profile in Firestore
  Future<void> createUserProfile(
    String userId,
    String email,
    String displayName,
    UserRole defaultRole,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
            'email': email,
            'displayName': displayName,
            'role': defaultRole.toString().split('.').last,
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          }, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Firestore operation timed out. Please check your internet connection and ensure Firestore is enabled.',
              );
            },
          );
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to create user profile in Firestore: $e');
    }
  }

  // Get user role from Firestore
  Future<UserRole> getUserRole(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Firestore read timed out');
            },
          );

      if (!doc.exists) {
        // User doesn't exist, return default role (don't create here to avoid recursion)
        return UserRole.pending;
      }

      final data = doc.data()!;
      final roleString = data['role'] as String? ?? 'pending';

      return _roleFromString(roleString);
    } catch (e) {
      // Default to pending if error - don't fail registration
      return UserRole.pending;
    }
  }

  // Get full user data from Firestore (including displayName)
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Firestore read timed out');
            },
          );

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      debugPrint('Error getting user data from Firestore: $e');
      return null;
    }
  }

  // Update user role (only superAdmin can do this)
  // Note: Permission check should be done in the UI/service layer
  Future<void> updateUserRole(
    String userId,
    UserRole newRole, {
    String? changedBy,
    String? reason,
  }) async {
    try {
      // Update user role
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Firestore update timed out');
        },
      );

      // Log the role change for audit trail
      if (changedBy != null) {
        try {
          await _firestore.collection('audit_logs').add({
            'action': 'role_changed',
            'userId': userId,
            'newRole': newRole.toString().split('.').last,
            'changedBy': changedBy,
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
          }).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Don't fail the role update if audit log fails
              debugPrint('Warning: Audit log write timed out');
              return _firestore.collection('audit_logs').doc(); // Return a dummy reference
            },
          );
        } catch (e) {
          // Don't fail the role update if audit log fails
          debugPrint('Warning: Failed to write audit log: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Get all users (for admin dashboard)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }).toList(),
        );
  }

  // Helper to convert string to UserRole
  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'pending':
        return UserRole.pending;
      case 'superadmin':
        return UserRole.superAdmin;
      case 'loadingadmin':
        return UserRole.loadingAdmin;
      case 'returnsadmin':
        return UserRole.returnsAdmin;
      case 'salesadmin':
        return UserRole.salesAdmin;
      default:
        return UserRole.pending;
    }
  }
}
