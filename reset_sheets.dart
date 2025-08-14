import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

// Helper function to get sheet ID by name
Future<int> _getSheetId(
  SheetsApi sheets,
  String spreadsheetId,
  String sheetName,
) async {
  final spreadsheet = await sheets.spreadsheets.get(spreadsheetId);
  final sheet = spreadsheet.sheets!.firstWhere(
    (s) => s.properties!.title == sheetName,
    orElse: () => throw Exception('Sheet "$sheetName" not found'),
  );
  return sheet.properties!.sheetId!;
}

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
    privateKey = privateKey.replaceAll(r'\n', '\n').replaceAll('"', '').trim();

    print('\n🔧 Creating service account credentials...');
    final credentials = ServiceAccountCredentials.fromJson({
      'private_key': privateKey,
      'client_email': clientEmail,
      'type': 'service_account',
    });

    print('\n🔐 Authenticating with Google...');
    final authClient = await clientViaServiceAccount(credentials, [
      SheetsApi.spreadsheetsScope,
    ], baseClient: http.Client());

    print('\n📊 Initializing Sheets API...');
    final sheets = SheetsApi(authClient);

    // Define headers for each sheet as a List<List<String>>
    final headers = [
      [
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
      ],
    ];

    // Create ValueRange with all required parameters
    final valueRange = ValueRange()
      ..values = headers;

    // Reset each sheet
    final sheetNames = ['LOADINGS', 'RETURNS'];

    for (final sheetName in sheetNames) {
      print('\n📝 Resetting sheet: $sheetName');

      try {
        // Clear the sheet
        await sheets.spreadsheets.values.clear(
          ClearValuesRequest(),
          spreadsheetId,
          '$sheetName!A:Z',
        );
        print('✅ Cleared existing data');

        // Add headers
        await sheets.spreadsheets.values.append(
          valueRange,
          spreadsheetId,
          '$sheetName!A1',
          valueInputOption: 'USER_ENTERED',
        );

        // Set date format for column A (date column)
        final dateFormatRequest = BatchUpdateSpreadsheetRequest(
          requests: [
            Request(
              repeatCell: RepeatCellRequest(
                range: GridRange(
                  sheetId: await _getSheetId(sheets, spreadsheetId, sheetName),
                  startRowIndex: 1, // Skip header row
                  startColumnIndex: 0, // Column A
                  endColumnIndex: 1,
                ),
                cell: CellData(
                  userEnteredFormat: CellFormat(
                    numberFormat: NumberFormat(
                      type: 'DATE',
                      pattern: 'yyyy-MM-dd',
                    ),
                  ),
                ),
                fields: 'userEnteredFormat.numberFormat',
              ),
            ),
          ],
        );

        await sheets.spreadsheets.batchUpdate(dateFormatRequest, spreadsheetId);
        print('✅ Added headers and set date format');
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
