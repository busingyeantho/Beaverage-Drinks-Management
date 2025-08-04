import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

final env = DotEnv(includePlatformEnvironment: true);

Future<void> main() async {
  try {
    // Load environment variables
    env.load();
    
    // Get credentials from environment
    final clientEmail = env['GOOGLE_SHEETS_CLIENT_EMAIL']!;
    String privateKey = env['GOOGLE_SHEETS_PRIVATE_KEY']!;
    final spreadsheetId = env['GOOGLE_SHEETS_SPREADSHEET_ID']!;

    print('🔑 Loaded environment variables');

    // Clean up the private key
    privateKey = privateKey.replaceAll('\\n', '\n');

    // Create service account credentials with all required fields
    final credentials = ServiceAccountCredentials.fromJson({
      'type': 'service_account',
      'private_key': privateKey,
      'client_email': clientEmail,
      'client_id': clientEmail.split('@').first,
      'token_uri': 'https://oauth2.googleapis.com/token',
    });

    print('🔑 Created service account credentials');

    // Create an authenticated HTTP client
    final authClient = await clientViaServiceAccount(
      credentials,
      [SheetsApi.spreadsheetsReadonlyScope],
      baseClient: http.Client(),
    );
    
    print('✅ Successfully authenticated with Google Sheets API');
    
    // Now you can use authClient to make API calls
    final sheets = SheetsApi(authClient);
    
    // Test the connection by getting spreadsheet info
    print('📋 Fetching spreadsheet info...');
    final spreadsheet = await sheets.spreadsheets.get(spreadsheetId);
    print('📄 Spreadsheet title: ${spreadsheet.properties?.title}');
    
    // List all sheets
    if (spreadsheet.sheets != null) {
      print('📑 Available sheets:');
      for (var sheet in spreadsheet.sheets!) {
        print('   - ${sheet.properties?.title} (ID: ${sheet.properties?.sheetId})');
      }
    }
  } catch (e, stackTrace) {
    print('❌ Error:');
    print(e);
    print('Stack trace:');
    print(stackTrace);
  }
}
