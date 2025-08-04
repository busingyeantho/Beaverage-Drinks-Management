import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/spreadsheets'],
  );

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // In a real app, you would fetch this from your backend
  // This is a simplified example
  UserRole _getUserRoleFromEmail(String email) {
    // This is just an example - in production, fetch roles from your database
    if (email.endsWith('@admin.com')) return UserRole.superAdmin;
    if (email.contains('loading')) return UserRole.loadingAdmin;
    if (email.contains('returns')) return UserRole.returnsAdmin;
    if (email.contains('sales')) return UserRole.salesAdmin;
    return UserRole.loadingAdmin; // Default role
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

      _currentUser = AppUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        role: _getUserRoleFromEmail(userCredential.user!.email!),
        displayName: userCredential.user!.displayName ?? 'User',
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
      _currentUser = AppUser(
        id: user.uid,
        email: user.email!,
        role: _getUserRoleFromEmail(user.email!),
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
      );
      notifyListeners();
    }
  }
}
