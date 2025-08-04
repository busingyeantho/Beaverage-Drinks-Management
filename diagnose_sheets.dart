import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/services/google_sheets_service.dart';

Future<void> main() async {
  try {
    print('🔍 Diagnosing Google Sheets Integration...\n');
    
    // Load environment variables
    await dotenv.load();
    print('✅ Environment variables loaded');
    
    // Check environment variables
    final spreadsheetId = dotenv.get('GOOGLE_SHEETS_SPREADSHEET_ID');
    final clientEmail = dotenv.get('GOOGLE_SHEETS_CLIENT_EMAIL');
    final privateKey = dotenv.get('GOOGLE_SHEETS_PRIVATE_KEY');
    
    print('\n📋 Environment Variables Check:');
    print('Spreadsheet ID: ${spreadsheetId.isNotEmpty ? '✓' : '✗'}');
    print('Client Email: ${clientEmail.isNotEmpty ? '✓' : '✗'}');
    print('Private Key: ${privateKey.isNotEmpty ? '✓' : '✗'}');
    
    if (spreadsheetId.isEmpty || clientEmail.isEmpty || privateKey.isEmpty) {
      print('\n❌ Missing environment variables! Please check your .env file.');
      return;
    }
    
    // Initialize service
    print('\n🔧 Initializing Google Sheets Service...');
    final sheetsService = GoogleSheetsService();
    print('✅ Service initialized');
    
    // Get sheet names
    print('\n📑 Getting available sheets...');
    final sheetNames = await sheetsService.getSheetNames();
    print('Available sheets: ${sheetNames.join(", ")}');
    
    // Check if required sheet exists
    final requiredSheet = 'LOADING AND RETURNS';
    final sheetExists = await sheetsService.sheetExists(requiredSheet);
    print('Required sheet "$requiredSheet": ${sheetExists ? '✓' : '✗'}');
    
    if (!sheetExists) {
      print('\n❌ Required sheet "$requiredSheet" not found!');
      print('Available sheets: ${sheetNames.join(", ")}');
      return;
    }
    
    // Test reading data
    print('\n📊 Testing data read...');
    final data = await sheetsService.getSheetData('$requiredSheet!A1:Z10');
    print('✅ Successfully read ${data.length} rows');
    
    if (data.isNotEmpty) {
      print('First row (headers): ${data[0]}');
      if (data.length > 1) {
        print('Second row (sample data): ${data[1]}');
      }
    }
    
    print('\n🎉 All tests passed! Google Sheets integration is working correctly.');
    
  } catch (e, stackTrace) {
    print('\n❌ Error during diagnosis:');
    print(e);
    print('\n📜 Stack trace:');
    print(stackTrace);
  }
} 