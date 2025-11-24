import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Service to manage Super Admin PIN/Secret Key for additional security
class PinService with ChangeNotifier {
  static const String _pinKey = 'super_admin_pin';
  static const String _pinSetKey = 'super_admin_pin_set';
  static const int _pinTimeoutMinutes = 15; // PIN expires after 15 minutes of inactivity
  static const int _pinLength = 6; // 6-digit PIN

  String? _currentPin;
  DateTime? _pinVerifiedAt;
  bool _isPinSet = false;

  PinService() {
    _loadPinStatus();
  }

  /// Check if PIN is currently verified (not expired)
  bool get isPinVerified {
    if (_currentPin == null || _pinVerifiedAt == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_pinVerifiedAt!);
    
    // PIN expires after timeout
    if (difference.inMinutes > _pinTimeoutMinutes) {
      _currentPin = null;
      _pinVerifiedAt = null;
      notifyListeners();
      return false;
    }
    
    return true;
  }

  /// Check if PIN has been set up
  bool get isPinSet => _isPinSet;

  /// Get remaining PIN validity time in minutes
  int? get remainingMinutes {
    if (!isPinVerified) return null;
    final now = DateTime.now();
    final difference = now.difference(_pinVerifiedAt!);
    return _pinTimeoutMinutes - difference.inMinutes;
  }

  /// Load PIN status from storage
  Future<void> _loadPinStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPinSet = prefs.getBool(_pinSetKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading PIN status: $e');
    }
  }

  /// Generate a random PIN (for first-time setup)
  String generateRandomPin() {
    final random = Random();
    final pin = List.generate(_pinLength, (_) => random.nextInt(10)).join();
    return pin;
  }

  /// Set up PIN for the first time
  Future<bool> setupPin(String pin) async {
    if (pin.length != _pinLength || !_isNumeric(pin)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // Store PIN hash (in production, use proper hashing like bcrypt)
      // For now, we'll use a simple approach - in production, hash it properly
      await prefs.setString(_pinKey, _hashPin(pin));
      await prefs.setBool(_pinSetKey, true);
      _isPinSet = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting up PIN: $e');
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    if (pin.length != _pinLength || !_isNumeric(pin)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_pinKey);
      
      if (storedHash == null) {
        return false;
      }

      final inputHash = _hashPin(pin);
      if (inputHash == storedHash) {
        _currentPin = pin;
        _pinVerifiedAt = DateTime.now();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error verifying PIN: $e');
      return false;
    }
  }

  /// Clear PIN verification (logout or timeout)
  void clearPinVerification() {
    _currentPin = null;
    _pinVerifiedAt = null;
    notifyListeners();
  }

  /// Reset PIN (requires current PIN verification)
  Future<bool> resetPin(String currentPin, String newPin) async {
    if (!await verifyPin(currentPin)) {
      return false;
    }

    return await setupPin(newPin);
  }

  /// Check if input is numeric
  bool _isNumeric(String str) {
    return int.tryParse(str) != null;
  }

  /// Simple hash function (in production, use proper hashing)
  String _hashPin(String pin) {
    // Simple hash - in production, use bcrypt or similar
    return pin.hashCode.toString();
  }

  /// Require PIN verification for sensitive operations
  /// Returns true if PIN is verified, false otherwise
  bool requirePinVerification() {
    if (!isPinVerified) {
      clearPinVerification();
      return false;
    }
    return true;
  }
}

