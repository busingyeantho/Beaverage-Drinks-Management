import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  try {
    print('🔍 Checking date format in Google Sheets...\n');

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

    // Check both sheets
    final sheetNames = ['LOADINGS', 'RETURNS'];
    
    for (final sheetName in sheetNames) {
      print('\n📝 Checking sheet: $sheetName');
      
      try {
        final response = await sheets.spreadsheets.values.get(
          spreadsheetId,
          '$sheetName!A1:Z10',
        );
        
        final data = response.values ?? [];
        
        if (data.isEmpty) {
          print('Sheet is empty');
          continue;
        }

        print('Headers: ${data[0]}');
        
        if (data.length > 1) {
          print('First data row: ${data[1]}');
          
          // Check the date column specifically
          if (data[1].isNotEmpty) {
            final dateValue = data[1][0];
            print('Date value: "$dateValue" (type: ${dateValue.runtimeType})');
            
            if (dateValue is DateTime) {
              print('Date is already a DateTime object: ${dateValue.toIso8601String()}');
            } else {
              print('Date is a string: "$dateValue"');
            }
          }
        }
        
      } catch (e) {
        print('❌ Error reading sheet $sheetName: $e');
      }
    }

    // Close the client
    authClient.close();

    print('\n✅ Date format check completed!');

  } catch (e, stackTrace) {
    print('\n❌ Error during date format check:');
    print(e);
    print('\n📜 Stack trace:');
    print(stackTrace);
  }
} 