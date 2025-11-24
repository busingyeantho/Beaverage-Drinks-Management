import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'role_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/spreadsheets'],
  );
  final RoleService _roleService = RoleService();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Register with email and password
  Future<AppUser?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) return null;

      // Update display name
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      // Create user document in Firestore with pending role (requires approval)
      try {
        await _roleService.createUserProfile(
          userCredential.user!.uid,
          email,
          name,
          UserRole.pending, // New users start as pending - Super Admin must approve
        );
      } catch (firestoreError) {
        debugPrint(
          'Warning: Could not create Firestore profile: $firestoreError',
        );
        // Continue even if Firestore fails - user is still created in Auth
      }

      // Get role from Firestore (with fallback)
      UserRole role;
      try {
        role = await _roleService.getUserRole(userCredential.user!.uid);
      } catch (e) {
        debugPrint('Warning: Could not get role from Firestore: $e');
        // Fallback to pending role if Firestore fails
        role = UserRole.pending;
      }

      _currentUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        role: role,
        displayName: name,
        photoUrl: userCredential.user!.photoURL,
      );

      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint('Error registering: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) return null;

      // Get role and user data from Firestore
      final role = await _roleService.getUserRole(userCredential.user!.uid);
      final userData = await _roleService.getUserData(userCredential.user!.uid);

      // Use displayName from Firestore if available, otherwise fallback to Auth or email
      final displayName = userData?['displayName'] as String? ??
          userCredential.user!.displayName ??
          email.split('@').first;

      _currentUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        role: role,
        displayName: displayName,
        photoUrl: userCredential.user!.photoURL,
      );

      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) return null;

      // Check if user exists in Firestore, create if not
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        // New user - create profile with pending role (requires approval)
        await _roleService.createUserProfile(
          userCredential.user!.uid,
          userCredential.user!.email!,
          userCredential.user!.displayName ?? 'User',
          UserRole.pending, // New users start as pending
        );
      }

      // Get role and user data from Firestore
      final role = await _roleService.getUserRole(userCredential.user!.uid);
      final userData = await _roleService.getUserData(userCredential.user!.uid);

      // Use displayName from Firestore if available, otherwise fallback to Auth or email
      final displayName = userData?['displayName'] as String? ??
          userCredential.user!.displayName ??
          userCredential.user!.email?.split('@').first ??
          'User';

      _currentUser = AppUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        role: role,
        displayName: displayName,
        photoUrl: userCredential.user!.photoURL,
      );

      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Call this when your app starts to check for existing session
  Future<void> checkAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Get role and user data from Firestore
      final role = await _roleService.getUserRole(user.uid);
      final userData = await _roleService.getUserData(user.uid);

      // Use displayName from Firestore if available, otherwise fallback to Auth or email
      final displayName = userData?['displayName'] as String? ??
          user.displayName ??
          user.email?.split('@').first ??
          'User';

      _currentUser = AppUser(
        id: user.uid,
        email: user.email!,
        role: role,
        displayName: displayName,
        photoUrl: user.photoURL,
      );
      notifyListeners();
    }
  }
}
