import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    // Load environment variables
    await dotenv.load();
    
    // Test if environment variables are loaded
    print('Testing environment variables...');
    
    final spreadsheetId = dotenv.get('GOOGLE_SHEETS_SPREADSHEET_ID');
    final clientEmail = dotenv.get('GOOGLE_SHEETS_CLIENT_EMAIL');
    final privateKey = dotenv.get('GOOGLE_SHEETS_PRIVATE_KEY');
    
    print('Spreadsheet ID: ${spreadsheetId.isNotEmpty ? '✓' : '✗'}');
    print('Client Email: ${clientEmail.isNotEmpty ? '✓' : '✗'}');
    print('Private Key: ${privateKey.isNotEmpty ? '✓' : '✗'}');
    
    if (spreadsheetId.isEmpty || clientEmail.isEmpty || privateKey.isEmpty) {
      print('\nError: One or more required environment variables are missing!');
      return;
    }
    
    print('\nEnvironment variables loaded successfully!');
  } catch (e, stackTrace) {
    print('Error:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
  }
}
