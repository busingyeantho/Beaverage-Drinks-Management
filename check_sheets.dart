import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Service account credentials from .env file
final _scopes = [SheetsApi.spreadsheetsReadonlyScope];

Future<void> main() async {
  try {
    // Load environment variables
    await dotenv.load();
    print('Initializing Google Sheets API client...');

    // Get environment variables
    final clientEmail = dotenv.get('GOOGLE_SHEETS_CLIENT_EMAIL');
    String privateKey = dotenv.get('GOOGLE_SHEETS_PRIVATE_KEY');
    
    // Clean up the private key
    privateKey = privateKey
        .replaceAll('\\n', '\n')  // Convert \\n to actual newlines
        .replaceAll('"', '')  // Remove any quotes
        .trim();
    
    print('Client Email: $clientEmail');
    print('Private Key starts with: ${privateKey.substring(0, 20)}...');

    // Create service account credentials
    final credentials = ServiceAccountCredentials.fromJson({
      'private_key': privateKey,
      'client_email': clientEmail,
      'type': 'service_account',
    });
    print('Successfully created credentials');

    // Create an authenticated HTTP client
    final authClient = await clientViaServiceAccount(
      credentials,
      _scopes,
      baseClient: http.Client(),
    );

    // Create the Sheets API client
    final sheets = SheetsApi(authClient);

    // Replace with your spreadsheet ID
    const spreadsheetId = '1WT1CGVxaHp2sVtka5ynU8SEef2m1GXJKNjOOEdus3Bc';

    if (spreadsheetId.isEmpty) {
      throw Exception('Spreadsheet ID is not set');
    }

    print('Fetching spreadsheet info...');
    final spreadsheet = await sheets.spreadsheets.get(spreadsheetId);
    print('Title: ${spreadsheet.properties?.title}');

    if (spreadsheet.sheets == null || spreadsheet.sheets!.isEmpty) {
      throw Exception('No sheets found in the spreadsheet');
    }

    print('\nAvailable Sheets:');
    for (var sheet in spreadsheet.sheets!) {
      final title = sheet.properties?.title ?? 'Untitled';
      final sheetId = sheet.properties?.sheetId;
      final rowCount = sheet.properties?.gridProperties?.rowCount;
      final colCount = sheet.properties?.gridProperties?.columnCount;
      print(
        '- "$title" (ID: $sheetId, Size: ${rowCount ?? '?'}x${colCount ?? '?'})',
      );

      // Try to get first row of each sheet
      try {
        final range = '$title!A1:Z1';
        print('  Getting headers from range: $range');
        final response = await sheets.spreadsheets.values.get(
          spreadsheetId,
          range,
        );
        final values = response.values;

        if (values == null || values.isEmpty) {
          print('  No data found in first row');
        } else {
          print('  First row data: ${values.first}');
        }
      } catch (e) {
        print('  Could not read data from sheet: $e');
      }
    }

    print('\nTesting data retrieval...');
    // Test getting data from the first sheet
    final firstSheet = spreadsheet.sheets!.first;
    final sheetTitle = firstSheet.properties?.title;
    if (sheetTitle != null) {
      final testRange = '$sheetTitle!A1:Z100';
      print('\nTesting range: $testRange');
      try {
        final response = await sheets.spreadsheets.values.get(
          spreadsheetId,
          testRange,
        );
        final values = response.values;

        if (values == null || values.isEmpty) {
          print('No data found in range $testRange');
        } else {
          print('Found ${values.length} rows of data:');
          for (var i = 0; i < (values.length > 5 ? 5 : values.length); i++) {
            print('  Row ${i + 1}: ${values[i]}');
          }
          if (values.length > 5) {
            print('  ... and ${values.length - 5} more rows');
          }
        }
      } catch (e) {
        print('Error reading data: $e');
      }
    }

    print('\nTest completed successfully!');
  } catch (e, stackTrace) {
    print('Error:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
  }
}
