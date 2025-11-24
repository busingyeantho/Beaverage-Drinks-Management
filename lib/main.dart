import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/returns_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/user_management_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_sheets_service.dart';
import 'services/pin_service.dart';
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
    // Load environment variables (for Google Sheets configuration)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Note: .env file not found or could not be loaded: $e');
      // Continue - Google Sheets service will try window config on web
    }

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize FirebaseSheetsService with your Firebase Functions URL
    final functionsBaseUrl =
        'https://us-central1-${DefaultFirebaseOptions.currentPlatform.projectId}.cloudfunctions.net';
    final firebaseSheetsService = FirebaseSheetsService(
      functionsBaseUrl: functionsBaseUrl,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => PinService()),
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
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/returns': (context) => const ReturnsScreen(),
        '/sales': (context) => const SalesScreen(),
        '/users': (context) => const UserManagementScreen(),
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

// AuthWrapper is now handled by SplashScreen

// LoginScreen is now in lib/screens/login_screen.dart
