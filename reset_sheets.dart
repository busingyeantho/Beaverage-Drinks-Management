import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  try {
    print('🔄 Resetting Google Sheets with proper headers...\n');

    // Load environment variables
    final env = DotEnv(includePlatformEnvironment: true);
    env.load();
    print('✅ Environment variables loaded');

    // Check environment variables
    final spreadsheetId = env['GOOGLE_SHEETS_SPREADSHEET_ID'] ?? '';
    final clientEmail = env['GOOGLE_SHEETS_CLIENT_EMAIL'] ?? '';
    String privateKey = env['GOOGLE_SHEETS_PRIVATE_KEY'] ?? '';

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

    print('\n🔐 Authenticating with Google...');
    final authClient = await clientViaServiceAccount(
      credentials,
      [SheetsApi.spreadsheetsScope],
      baseClient: http.Client(),
    );

    print('\n📊 Initializing Sheets API...');
    final sheets = SheetsApi(authClient);

    // Define headers for each sheet
    final headers = [
      'Date',
      'Driver Name',
      'Vehicle Number',
      'B-Steady 24x200ml',
      'B-Steady Pieces',
      'B-Steady 12x200ml',
      'Jim Pombe 24x200ml',
      'Jim Pombe 12x200ml',
      'Jim Pombe Pieces',
      'Notes',
    ];

    // Reset each sheet
    final sheetNames = ['LOADINGS', 'RETURNS'];
    
    for (final sheetName in sheetNames) {
      print('\n📝 Resetting sheet: $sheetName');
      
      try {
        // Clear the sheet
        await sheets.spreadsheets.values.clear(
          spreadsheetId,
          '$sheetName!A:Z',
          ClearValuesRequest(),
        );
        print('✅ Cleared existing data');

        // Add headers
        await sheets.spreadsheets.values.append(
          spreadsheetId,
          '$sheetName!A1',
          ValueRange(values: [headers]),
          valueInputOption: 'RAW',
        );
        print('✅ Added headers');
        
      } catch (e) {
        print('❌ Error with sheet $sheetName: $e');
      }
    }

    // Close the client
    authClient.close();

    print('\n🎉 Sheets reset successfully!');
    print('\n📋 Headers added to each sheet:');
    print(headers.join(' | '));

  } catch (e, stackTrace) {
    print('\n❌ Error during reset:');
    print(e);
    print('\n📜 Stack trace:');
    print(stackTrace);
  }
} 