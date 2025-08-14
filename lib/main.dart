import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'screens/returns_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/main_menu_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_sheets_service.dart';
import 'widgets/role_guard.dart';
import 'models/user_model.dart';
import 'firebase_options.dart';

// Helper function to get config value
String _getConfigValue(String key, {String? defaultValue}) {
  // This function is kept for backward compatibility
  // In the new implementation, we'll use Firebase Remote Config or environment variables
  if (defaultValue != null) return defaultValue;
  throw Exception('$key not found in environment variables');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('App starting...');
  FlutterError.onError = (details) {
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrint('STACK TRACE: ${details.stack}');
  };

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize FirebaseSheetsService with your Firebase Functions URL
    final functionsBaseUrl = 'https://us-central1-${DefaultFirebaseOptions.currentPlatform.projectId}.cloudfunctions.net';
    final firebaseSheetsService = FirebaseSheetsService(functionsBaseUrl: functionsBaseUrl);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          Provider<FirebaseSheetsService>.value(value: firebaseSheetsService),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
    // Run the app with an error widget if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize app: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'John Pombe',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/loading': (context) => const LoadingScreen(),
        '/returns': (context) => const ReturnsScreen(),
        '/sales': (context) => const SalesScreen(),
        // Add other routes here
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Removed the 'home' property to avoid conflict with the '/' route
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Bypass authentication for now and go directly to the main menu
    return const MainMenuScreen();

    // Uncomment the code below to re-enable authentication later
    /*
    final authService = Provider.of<AuthService>(context);

    return FutureBuilder<void>(
      future: authService.checkAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (authService.isAuthenticated) {
            // Redirect based on user role
            final user = authService.currentUser!;
            if (user.role == UserRole.superAdmin ||
                user.role == UserRole.loadingAdmin) {
              return const LoadingScreen();
            }
            // Add other role-based redirections here
            return const Scaffold(body: Center(child: Text('Welcome!')));
          } else {
            return const LoginScreen();
          }
        }
        // Show a loading indicator while checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
    */
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Starting Google Sign In...');
      final authService = context.read<AuthService>();
      final user = await authService.signInWithGoogle();

      if (mounted) {
        if (user != null) {
          print('User signed in successfully: ${user.email}');
          // Navigate based on role
          if (user.role == UserRole.superAdmin ||
              user.role == UserRole.loadingAdmin) {
            print('Navigating to loading screen...');
            Navigator.of(context).pushReplacementNamed('/loading');
          } else {
            print('No route defined for role: ${user.role}');
            setState(() {
              _errorMessage = 'No access granted for this role';
            });
          }
        } else {
          print('User sign in was cancelled or failed');
          setState(() {
            _errorMessage = 'Sign in was cancelled or failed';
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error during sign in: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error during sign in: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Signing in...'),
            ] else
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text('Sign in with Google'),
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
