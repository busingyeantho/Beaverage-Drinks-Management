import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/pin_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'main_menu_screen.dart';
import 'pin_entry_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkAuthState();

    if (!mounted) return;

    // Navigate based on auth state
    if (authService.isAuthenticated) {
      final user = authService.currentUser;
      
      // If Super Admin, check PIN requirement
      if (user?.role == UserRole.superAdmin) {
        final pinService = Provider.of<PinService>(context, listen: false);
        
        // Check if PIN is set up
        if (!pinService.isPinSet) {
          // First time - generate PIN and show setup
          final generatedPin = pinService.generateRandomPin();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PinEntryScreen(
                isFirstTime: true,
                generatedPin: generatedPin,
              ),
            ),
          );
          return;
        }
        
        // PIN is set - check if verified
        if (!pinService.isPinVerified) {
          // Need to enter PIN
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PinEntryScreen()),
          );
          return;
        }
      }
      
      // Regular users or Super Admin with verified PIN
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade400,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon with animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_drink,
                      size: 70,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'John Pombe',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Beverage Logistics Management',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


