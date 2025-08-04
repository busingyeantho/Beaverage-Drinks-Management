import 'package:flutter/material.dart' as material;
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load environment variables
  await dotenv.load();

  // Get credentials
  final clientEmail = dotenv.get('GOOGLE_SHEETS_CLIENT_EMAIL');
  String privateKey = dotenv.get('GOOGLE_SHEETS_PRIVATE_KEY');
  final spreadsheetId = dotenv.get('GOOGLE_SHEETS_SPREADSHEET_ID');

  // Clean up the private key
  privateKey =
      privateKey
          .replaceAll('\\n', '\n') // Convert \\n to actual newlines
          .replaceAll('"', '') // Remove any quotes
          .trim();

  print('Initializing Google Sheets API...');
  print('Client Email: $clientEmail');
  print('Spreadsheet ID: $spreadsheetId');

  try {
    // Create service account credentials with all required fields
    final credentials = ServiceAccountCredentials.fromJson({
      'private_key': privateKey,
      'client_email': clientEmail,
      'type': 'service_account',
      'client_id':
          '${clientEmail.split('@')[0]}', // Generate a client ID from the email
      'token_uri': 'https://oauth2.googleapis.com/token',
    });

    print('Creating authenticated client...');

    // Create an authenticated HTTP client
    final authClient = await clientViaServiceAccount(credentials, [
      SheetsApi.spreadsheetsReadonlyScope,
    ], baseClient: http.Client());
    print('Authentication successful');

    print('Authentication successful');

    // Create the Sheets API client
    final sheets = SheetsApi(authClient);

    // Test reading the spreadsheet
    print('Fetching spreadsheet info...');
    final spreadsheet = await sheets.spreadsheets.get(spreadsheetId);
    print('Spreadsheet Title: ${spreadsheet.properties?.title}');

    // Get all sheet names with their IDs
    final sheetNames = <String>[];
    if (spreadsheet.sheets != null) {
      for (var sheet in spreadsheet.sheets!) {
        final title = sheet.properties?.title ?? 'Untitled';
        final id = sheet.properties?.sheetId;
        print('Found sheet: "$title" (ID: $id)');
        sheetNames.add(title);
      }
    }

    if (sheetNames.isEmpty) {
      throw Exception('No sheets found in the spreadsheet');
    }

    // Look for the 'LOADING AND RETURNS' sheet (case insensitive)
    String? targetSheet;
    for (final name in sheetNames) {
      if (name.toUpperCase() == 'LOADING AND RETURNS') {
        targetSheet = name; // Preserve the exact case used in the sheet
        break;
      }
    }

    // If not found, show error with available sheets
    if (targetSheet == null) {
      final availableSheets = sheetNames.map((s) => '"$s"').join(', ');
      throw Exception(
        'Could not find "LOADING AND RETURNS" sheet. Available sheets: $availableSheets',
      );
    }

    print('Using sheet: "$targetSheet"');

    material.runApp(
      MyApp(
        spreadsheetTitle: spreadsheet.properties?.title ?? 'No title',
        sheets: sheetNames,
        targetSheet: targetSheet,
        sheetsApi: sheets,
        spreadsheetId: spreadsheetId,
      ),
    );
  } catch (e, stackTrace) {
    print('Error:');
    print(e);
    print('Stack trace:');
    print(stackTrace);

    material.runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends material.StatefulWidget {
  final String spreadsheetTitle;
  final List<String> sheets;
  final String targetSheet;
  final SheetsApi sheetsApi;
  final String spreadsheetId;

  const MyApp({
    material.Key? key,
    required this.spreadsheetTitle,
    required this.sheets,
    required this.targetSheet,
    required this.sheetsApi,
    required this.spreadsheetId,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends material.State<MyApp> {
  List<List<dynamic>>? sheetData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.targetSheet.isNotEmpty) {
      _loadSheetData(widget.targetSheet);
    } else {
      setState(() {
        isLoading = false;
        error = 'No target sheet found';
      });
    }
  }

  Future<void> _loadSheetData(String sheetName) async {
    print('Starting to load data from sheet: "$sheetName"');
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // First, try to get the actual sheet to verify it exists
      try {
        final spreadsheet = await widget.sheetsApi.spreadsheets.get(
          widget.spreadsheetId,
        );
        final sheetExists =
            spreadsheet.sheets?.any((s) => s.properties?.title == sheetName) ??
            false;

        if (!sheetExists) {
          final availableSheets =
              spreadsheet.sheets
                  ?.map((s) => '"${s.properties?.title}"')
                  .join(', ') ??
              'none';
          throw Exception(
            'Sheet "$sheetName" not found. Available sheets: $availableSheets',
          );
        }
      } catch (e) {
        print('Error verifying sheet existence: $e');
        rethrow;
      }

      // Now try to get the data
      try {
        // Try with the exact sheet name first (with proper escaping for special characters)
        final range = "'${sheetName.replaceAll("'", "''")}'!A:Z";
        print('Attempting to fetch data from range: $range');

        final response = await widget.sheetsApi.spreadsheets.values.get(
          widget.spreadsheetId,
          range,
        );

        print('API Response Status: ${response.range}');

        if (response.values == null || response.values!.isEmpty) {
          throw Exception('No data found in the specified range');
        }

        print('Successfully fetched ${response.values!.length} rows of data');
        setState(() {
          sheetData = response.values!;
          isLoading = false;
        });
        return;
      } catch (e) {
        print('Error with first attempt: $e');
      }

      // If first attempt fails, try with single quotes around sheet name
      try {
        final quotedRange = "'${sheetName.replaceAll("'", "''")}'!A:Z";
        print('Trying with quoted range: $quotedRange');
        final response = await widget.sheetsApi.spreadsheets.values.get(
          widget.spreadsheetId,
          quotedRange,
        );

        if (response.values == null || response.values!.isEmpty) {
          throw Exception('No data found in the specified range');
        }

        print(
          'Successfully fetched ${response.values!.length} rows with quoted range',
        );
        setState(() {
          sheetData = response.values!;
          isLoading = false;
        });
        return;
      } catch (e) {
        print('Error with quoted range attempt: $e');
      }

      // If still failing, try with a smaller range
      try {
        final smallRange = "'${sheetName.replaceAll("'", "''")}'!A1:Z10";
        print('Trying with smaller range: $smallRange');
        final response = await widget.sheetsApi.spreadsheets.values.get(
          widget.spreadsheetId,
          smallRange,
        );

        if (response.values == null || response.values!.isEmpty) {
          throw Exception('No data found in any range');
        }

        print(
          'Successfully fetched ${response.values!.length} rows with small range',
        );
        setState(() {
          sheetData = response.values!;
          isLoading = false;
        });
      } catch (e) {
        throw Exception('All attempts failed. Last error: $e');
      }
    } catch (e) {
      final errorMsg = 'Failed to load data: $e';
      print(errorMsg);
      setState(() {
        error = errorMsg;
        isLoading = false;
      });
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.MaterialApp(
      home: material.Scaffold(
        appBar: material.AppBar(
          title: material.Text('Google Sheets - ${widget.spreadsheetTitle}'),
        ),
        body: material.Padding(
          padding: const material.EdgeInsets.all(16.0),
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Text(
                'Loading data from sheet: ${widget.targetSheet}',
                style: const material.TextStyle(
                  fontSize: 16,
                  fontWeight: material.FontWeight.bold,
                ),
              ),
              const material.SizedBox(height: 16),

              if (isLoading)
                const material.Center(
                  child: material.CircularProgressIndicator(),
                )
              else if (error != null)
                material.Text(
                  'Error: $error',
                  style: const material.TextStyle(color: material.Colors.red),
                )
              else if (sheetData == null || sheetData!.isEmpty)
                const material.Text('No data available')
              else
                material.Expanded(
                  child: material.SingleChildScrollView(
                    scrollDirection: material.Axis.vertical,
                    child: material.SingleChildScrollView(
                      scrollDirection: material.Axis.horizontal,
                      child: material.DataTable(
                        columns:
                            sheetData!.first.asMap().entries.map((entry) {
                              return material.DataColumn(
                                label: material.Text(
                                  '${entry.value ?? 'Column ${entry.key + 1}'}',
                                  style: const material.TextStyle(
                                    fontWeight: material.FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                        rows:
                            sheetData!.length > 1
                                ? sheetData!.sublist(1).map((row) {
                                  return material.DataRow(
                                    cells:
                                        row
                                            .asMap()
                                            .entries
                                            .map(
                                              (cell) => material.DataCell(
                                                material.Text(
                                                  cell.value?.toString() ?? '',
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  );
                                }).toList()
                                : [
                                  material.DataRow(
                                    cells: [
                                      material.DataCell(
                                        const material.Text('No data rows'),
                                      ),
                                    ],
                                  ),
                                ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends material.StatelessWidget {
  final String error;

  const ErrorApp({material.Key? key, required this.error}) : super(key: key);

  @override
  material.Widget build(material.BuildContext context) {
    return material.MaterialApp(
      home: material.Scaffold(
        appBar: material.AppBar(
          title: const material.Text('Error'),
          backgroundColor: material.Colors.red,
        ),
        body: material.Padding(
          padding: const material.EdgeInsets.all(16.0),
          child: material.Text(
            'Error accessing Google Sheets:\n\n$error',
            style: const material.TextStyle(
              color: material.Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
