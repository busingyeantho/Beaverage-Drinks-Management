import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pin_service.dart';
import '../services/auth_service.dart';
import 'main_menu_screen.dart';

/// Screen for Super Admin to enter PIN/Secret Key for additional security
class PinEntryScreen extends StatefulWidget {
  final bool isFirstTime;
  final String? generatedPin;

  const PinEntryScreen({
    super.key,
    this.isFirstTime = false,
    this.generatedPin,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final List<String> _enteredDigits = [];
  final int _pinLength = 6;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isFirstTime && widget.generatedPin != null) {
      // Show the generated PIN for first-time setup
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGeneratedPinDialog();
      });
    }
  }

  void _showGeneratedPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Your Security PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please save this PIN securely. You will need it to perform Super Admin operations.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Text(
                widget.generatedPin!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Write this down! You cannot recover it if lost.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I\'ve Saved It'),
          ),
        ],
      ),
    );
  }

  void _addDigit(String digit) {
    if (_enteredDigits.length < _pinLength) {
      setState(() {
        _enteredDigits.add(digit);
        _errorMessage = null;
      });

      // Auto-submit when PIN is complete
      if (_enteredDigits.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _removeDigit() {
    if (_enteredDigits.isNotEmpty) {
      setState(() {
        _enteredDigits.removeLast();
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_enteredDigits.length != _pinLength) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final pinService = Provider.of<PinService>(context, listen: false);
    final pin = _enteredDigits.join('');

    if (widget.isFirstTime) {
      // First-time setup
      final success = await pinService.setupPin(pin);
      if (mounted) {
        if (success) {
          _navigateToDashboard();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to set up PIN. Please try again.';
            _enteredDigits.clear();
          });
        }
      }
    } else {
      // Verify existing PIN
      final success = await pinService.verifyPin(pin);
      if (mounted) {
        if (success) {
          _navigateToDashboard();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Incorrect PIN. Please try again.';
            _enteredDigits.clear();
          });
        }
      }
    }
  }

  void _navigateToDashboard() {
    if (widget.isFirstTime) {
      // First time setup - go to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    } else {
      // PIN verified - return to previous screen
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Security Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Security Verification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    widget.isFirstTime
                        ? 'Set up your security PIN'
                        : 'Enter your security PIN',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (currentUser != null)
                    Text(
                      'Super Admin: ${currentUser.displayName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // PIN Display
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pinLength,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _enteredDigits.length
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  if (_isLoading) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Number Pad
                  _buildNumberPad(),

                  const SizedBox(height: 24),

                  // Info Text
                  Text(
                    widget.isFirstTime
                        ? 'This PIN protects your Super Admin operations'
                        : 'PIN expires after 15 minutes of inactivity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('1'),
            const SizedBox(width: 16),
            _buildNumberButton('2'),
            const SizedBox(width: 16),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('4'),
            const SizedBox(width: 16),
            _buildNumberButton('5'),
            const SizedBox(width: 16),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('7'),
            const SizedBox(width: 16),
            _buildNumberButton('8'),
            const SizedBox(width: 16),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80), // Spacer
            _buildNumberButton('0'),
            const SizedBox(width: 16),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addDigit(digit),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _removeDigit,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.3),
            border: Border.all(
              color: Colors.red.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.backspace_outlined,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

