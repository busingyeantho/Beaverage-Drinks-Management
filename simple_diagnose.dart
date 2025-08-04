import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  try {
    print('🔍 Diagnosing Google Sheets Integration...\n');
    
    // Load environment variables
    final env = DotEnv(includePlatformEnvironment: true);
    env.load();
    print('✅ Environment variables loaded');
    
    // Check environment variables
    final spreadsheetId = env['GOOGLE_SHEETS_SPREADSHEET_ID'] ?? '';
    final clientEmail = env['GOOGLE_SHEETS_CLIENT_EMAIL'] ?? '';
    String privateKey = env['GOOGLE_SHEETS_PRIVATE_KEY'] ?? '';
    
    print('\n📋 Environment Variables Check:');
    print('Spreadsheet ID: ${spreadsheetId.isNotEmpty ? '✓' : '✗'}');
    print('Client Email: ${clientEmail.isNotEmpty ? '✓' : '✗'}');
    print('Private Key: ${privateKey.isNotEmpty ? '✓' : '✗'}');
    
    if (spreadsheetId.isEmpty || clientEmail.isEmpty || privateKey.isEmpty) {
      print('\n❌ Missing environment variables! Please check your .env file.');
      return;
    }
    
    // Clean up the private key
    privateKey = privateKey
        .replaceAll(r'\n', '\n')
        .replaceAll('"', '')
        .trim();
    
    print('\n🔧 Creating service account credentials...');
    final credentials = ServiceAccountCredentials.fromJson({
      'private_key': privateKey,
      'client_email': clientEmail,
      'type': 'service_account',
    });
    print('✅ Credentials created');
    
    print('\n🔐 Authenticating with Google...');
    final authClient = await clientViaServiceAccount(
      credentials,
      [SheetsApi.spreadsheetsScope],
      baseClient: http.Client(),
    );
    print('✅ Authentication successful');
    
    print('\n📊 Initializing Sheets API...');
    final sheets = SheetsApi(authClient);
    print('✅ Sheets API initialized');
    
    // Get sheet names
    print('\n📑 Getting available sheets...');
    final spreadsheet = await sheets.spreadsheets.get(spreadsheetId);
    final sheetNames = spreadsheet.sheets?.map((s) => s.properties!.title!).toList() ?? [];
    print('Available sheets: ${sheetNames.join(", ")}');
    
    // Check if required sheet exists
    final requiredSheet = 'LOADING AND RETURNS';
    final sheetExists = sheetNames.contains(requiredSheet);
    print('Required sheet "$requiredSheet": ${sheetExists ? '✓' : '✗'}');
    
    if (!sheetExists) {
      print('\n❌ Required sheet "$requiredSheet" not found!');
      print('Available sheets: ${sheetNames.join(", ")}');
      return;
    }
    
    // Test reading data
    print('\n📊 Testing data read...');
    final response = await sheets.spreadsheets.values.get(
      spreadsheetId,
      '$requiredSheet!A1:Z10',
    );
    final data = response.values ?? [];
    print('✅ Successfully read ${data.length} rows');
    
    if (data.isNotEmpty) {
      print('First row (headers): ${data[0]}');
      if (data.length > 1) {
        print('Second row (sample data): ${data[1]}');
      }
    }
    
    // Close the client
    authClient.close();
    
    print('\n🎉 All tests passed! Google Sheets integration is working correctly.');
    
  } catch (e, stackTrace) {
    print('\n❌ Error during diagnosis:');
    print(e);
    print('\n📜 Stack trace:');
    print(stackTrace);
  }
} 