import 'package:flutter_test/flutter_test.dart';
import 'package:john_pombe/services/google_sheets_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Test Google Sheets Service Initialization', () async {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Try to initialize the service
    try {
      final sheetsService = GoogleSheetsService();
      expect(sheetsService, isNotNull);
      print('Google Sheets Service initialized successfully');
    } catch (e) {
      print('Error initializing Google Sheets Service: $e');
      rethrow;
    }
  });
}
