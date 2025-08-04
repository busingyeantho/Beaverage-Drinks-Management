import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  try {
    // Load environment variables
    final env = DotEnv(includePlatformEnvironment: true);
    env.load();

    // Get credentials from environment
    final clientEmail = env['GOOGLE_SHEETS_CLIENT_EMAIL']!;
    String privateKey = env['GOOGLE_SHEETS_PRIVATE_KEY']!;
    final spreadsheetId = env['GOOGLE_SHEETS_SPREADSHEET_ID']!;

    print('🔑 Loaded environment variables');

    // Clean up the private key
    privateKey =
        privateKey
            .replaceAll(r'\n', '\n') // Handle escaped newlines
            .replaceAll('"', '') // Remove any quotes
            .trim();

    print('ℹ️ Client Email: $clientEmail');
    print('ℹ️ Spreadsheet ID: $spreadsheetId');

    // Create service account credentials
    print('🔑 Creating service account credentials...');
    final credentials = ServiceAccountCredentials.fromJson({
      'private_key': privateKey,
      'client_email': clientEmail,
      'type': 'service_account',
    });

    print('✅ Credentials created successfully');

    // Create an authenticated HTTP client
    print('🔐 Authenticating with Google...');
    final authClient = await clientViaServiceAccount(credentials, [
      SheetsApi.spreadsheetsReadonlyScope,
    ], baseClient: http.Client());

    print('✅ Authentication successful');

    // Create the Sheets API client
    print('📊 Initializing Sheets API...');
    final sheets = SheetsApi(authClient);

    // Test reading the spreadsheet
    print('📋 Fetching spreadsheet info...');
    final spreadsheet = await sheets.spreadsheets.get(spreadsheetId);

    print('\n🎉 Success! Connected to Google Sheets');
    print('📄 Spreadsheet Title: ${spreadsheet.properties?.title}');
    print('📑 Sheets in this document:');

    if (spreadsheet.sheets != null) {
      for (var sheet in spreadsheet.sheets!) {
        final title = sheet.properties?.title ?? 'Untitled';
        final rowCount = sheet.properties?.gridProperties?.rowCount ?? 0;
        final colCount = sheet.properties?.gridProperties?.columnCount ?? 0;
        print('   • $title (${rowCount}x$colCount)');
      }
    }

    // Test reading data from the first sheet
    if (spreadsheet.sheets?.isNotEmpty ?? false) {
      final firstSheet = spreadsheet.sheets!.first;
      final sheetName = firstSheet.properties?.title ?? 'Sheet1';
      print('\n📊 Testing data read from "$sheetName"...');

      final range = '$sheetName!A1:Z100';
      final response = await sheets.spreadsheets.values.get(
        spreadsheetId,
        range,
      );

      if (response.values == null || response.values!.isEmpty) {
        print('ℹ️ No data found in range $range');
      } else {
        print('📋 Found ${response.values!.length} rows of data:');
        for (
          var i = 0;
          i < (response.values!.length > 5 ? 5 : response.values!.length);
          i++
        ) {
          print('   ${response.values![i]}');
        }
        if (response.values!.length > 5) {
          print('   ... and ${response.values!.length - 5} more rows');
        }
      }
    }

    // Close the client when done
    authClient.close();
    print('\n✅ All done!');
  } catch (e, stackTrace) {
    print('\n❌ Error:');
    print(e);
    print('\n📜 Stack trace:');
    print(stackTrace);
    exit(1);
  }
}
