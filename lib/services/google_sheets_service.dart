import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleSheetsException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  GoogleSheetsException(this.message, {this.error, StackTrace? st})
    : stackTrace = st ?? StackTrace.current;

  @override
  String toString() => 'GoogleSheetsException: $message\nError: $error';
}

class SheetNotFoundException implements Exception {
  final String message;
  SheetNotFoundException(this.message);

  @override
  String toString() => 'SheetNotFoundException: $message';
}

class GoogleSheetsService {
  final String _spreadsheetId;
  final String _clientEmail;
  final String _privateKey;

  GoogleSheetsService()
    : _spreadsheetId = _getConfigValue('GOOGLE_SHEETS_SPREADSHEET_ID'),
      _clientEmail = _getConfigValue('GOOGLE_SHEETS_CLIENT_EMAIL'),
      _privateKey = _getConfigValue('GOOGLE_SHEETS_PRIVATE_KEY')
          .replaceAll(r'\n', '\n') {
    _validateEnvironment();
  }

  // Helper function to get config value from either window object or .env file
  static String _getConfigValue(String key) {
    try {
      // Try to get from window.appConfiguration first (new structure)
      if (kIsWeb && js.context.hasProperty('appConfiguration')) {
        try {
          final config = js.JsObject.fromBrowserObject(js.context['appConfiguration']);
          if (config.hasProperty(key)) {
            final value = config[key];
            if (value != null) {
              debugPrint('Config value for $key found in window.appConfiguration');
              return value.toString();
            }
          }
        } catch (e) {
          debugPrint('Error accessing window.appConfiguration: $e');
        }
      }
      
      // Try to get from window.flutterConfiguration (legacy fallback)
      if (kIsWeb && js.context.hasProperty('flutterConfiguration')) {
        try {
          final config = js.JsObject.fromBrowserObject(js.context['flutterConfiguration']);
          if (config.hasProperty(key)) {
            final value = config[key];
            if (value != null) {
              debugPrint('Config value for $key found in window.flutterConfiguration (legacy)');
              return value.toString();
            }
          }
        } catch (e) {
          debugPrint('Error accessing window.flutterConfiguration: $e');
        }
      }
      
      // Fall back to .env file
      return dotenv.get(key);
    } catch (e) {
      debugPrint('Error getting config value for $key: $e');
      rethrow;
    }
  }

  void _validateEnvironment() {
    if (_spreadsheetId.isEmpty || _clientEmail.isEmpty || _privateKey.isEmpty) {
      throw GoogleSheetsException(
        'Missing required Google Sheets environment variables. Please check your .env file.\n'
        'Required variables:\n'
        '- GOOGLE_SHEETS_SPREADSHEET_ID: ${_spreadsheetId.isEmpty ? "MISSING" : "✓"}\n'
        '- GOOGLE_SHEETS_CLIENT_EMAIL: ${_clientEmail.isEmpty ? "MISSING" : "✓"}\n'
        '- GOOGLE_SHEETS_PRIVATE_KEY: ${_privateKey.isEmpty ? "MISSING" : "✓"}',
      );
    }
  }

  Map<String, dynamic> get _credentials => {
    'type': 'service_account',
    'private_key': _privateKey,
    'client_email': _clientEmail,
    'client_id': _clientEmail.split('@').first,
    'token_uri': 'https://oauth2.googleapis.com/token',
  };

  static const _scopes = [SheetsApi.spreadsheetsScope];
  static const _maxRetries = 3;
  static const _retryDelay = Duration(seconds: 1);

  SheetsApi? _sheetsApi;
  AutoRefreshingAuthClient? _client;

  Future<SheetsApi> get _api async {
    if (_sheetsApi == null) {
      await _initialize();
    }
    return _sheetsApi!;
  }

  Future<void> _initialize() async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(_credentials);

      _client = await clientViaServiceAccount(
        credentials,
        _scopes,
        baseClient: http.Client(),
      );

      _sheetsApi = SheetsApi(_client!);
    } catch (e, st) {
      throw GoogleSheetsException(
        'Failed to initialize Google Sheets API',
        error: e,
        st: st,
      );
    }
  }

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (++attempt >= _maxRetries) rethrow;
        await Future.delayed(_retryDelay * attempt);
      }
    }
  }

  /// Gets data from the specified range
  Future<List<List<dynamic>>> getSheetData(String range) async {
    return _withRetry(() async {
      try {
        final response = await (await _api).spreadsheets.values.get(
          _spreadsheetId,
          range,
        );
        return response.values ?? [];
      } catch (e, st) {
        throw GoogleSheetsException(
          'Failed to get sheet data for range: $range',
          error: e,
          st: st,
        );
      }
    });
  }

  /// Gets a specific row by index (1-based)
  Future<List<dynamic>?> getRow(String sheetName, int rowIndex) async {
    final range = '$sheetName!A$rowIndex:Z$rowIndex';
    final result = await getSheetData(range);
    return result.isNotEmpty ? result.first : null;
  }

  /// Gets a specific column by letter (e.g., 'A', 'B', 'C')
  Future<List<dynamic>> getColumn(String sheetName, String column) async {
    final range = '$sheetName!${column}2:$column';
    final result = await getSheetData(range);
    return result.expand((row) => row).toList();
  }

  /// Appends a new row to the specified range
  Future<void> appendRow(String range, List<dynamic> row) async {
    await _withRetry(() async {
      try {
        final valueRange = ValueRange()..values = [row];
        await (await _api).spreadsheets.values.append(
          valueRange,
          _spreadsheetId,
          range,
          valueInputOption: 'USER_ENTERED',
          insertDataOption: 'INSERT_ROWS',
        );
      } catch (e, st) {
        throw GoogleSheetsException(
          'Failed to append row to range: $range',
          error: e,
          st: st,
        );
      }
    });
  }

  /// Updates an existing row in the specified range
  Future<void> updateRow(String range, List<dynamic> row) async {
    await _withRetry(() async {
      try {
        final valueRange = ValueRange()..values = [row];
        await (await _api).spreadsheets.values.update(
          valueRange,
          _spreadsheetId,
          range,
          valueInputOption: 'USER_ENTERED',
        );
      } catch (e, st) {
        throw GoogleSheetsException(
          'Failed to update row in range: $range',
          error: e,
          st: st,
        );
      }
    });
  }

  /// Deletes a row by its index (1-based)
  Future<void> deleteRow(String sheetName, int rowIndex) async {
    await _withRetry(() async {
      try {
        // First, get the sheet ID for the given sheet name
        final spreadsheet = await (await _api).spreadsheets.get(_spreadsheetId);
        final sheet = spreadsheet.sheets?.firstWhere(
          (s) => s.properties?.title == sheetName,
          orElse: () => throw SheetNotFoundException(sheetName),
        );

        final sheetId = sheet!.properties!.sheetId!;

        // Create the dimension range
        final dimensionRange =
            DimensionRange()
              ..sheetId = sheetId
              ..dimension = 'ROWS'
              ..startIndex =
                  rowIndex -
                  1 // Convert to 0-based index
              ..endIndex = rowIndex; // End index is exclusive

        // Create the delete dimension request
        final deleteRequest = DeleteDimensionRequest()..range = dimensionRange;

        // Create the batch update request
        final request =
            BatchUpdateSpreadsheetRequest()
              ..requests = [Request()..deleteDimension = deleteRequest];

        await (await _api).spreadsheets.batchUpdate(request, _spreadsheetId);
      } catch (e, st) {
        throw GoogleSheetsException(
          'Failed to delete row at index: $rowIndex',
          error: e,
          st: st,
        );
      }
    });
  }

  /// Performs a batch update with multiple operations
  Future<void> batchUpdate(
    List<MapEntry<String, List<dynamic>>> updates,
  ) async {
    await _withRetry(() async {
      try {
        final batchUpdate =
            BatchUpdateValuesRequest()
              ..data =
                  updates
                      .map(
                        (e) =>
                            ValueRange()
                              ..range = e.key
                              ..values = [e.value],
                      )
                      .toList()
              ..valueInputOption = 'USER_ENTERED';

        await (await _api).spreadsheets.values.batchUpdate(
          batchUpdate,
          _spreadsheetId,
        );
      } catch (e, st) {
        throw GoogleSheetsException(
          'Failed to perform batch update',
          error: e,
          st: st,
        );
      }
    });
  }

  /// Gets all sheet names in the spreadsheet
  Future<List<String>> getSheetNames() async {
    return _withRetry(() async {
      try {
        final spreadsheet = await (await _api).spreadsheets.get(_spreadsheetId);
        return spreadsheet.sheets?.map((s) => s.properties!.title!).toList() ??
            [];
      } catch (e, st) {
        throw GoogleSheetsException(
          'Failed to get sheet names',
          error: e,
          st: st,
        );
      }
    });
  }

  /// Validates that a specific sheet exists
  Future<bool> sheetExists(String sheetName) async {
    final sheetNames = await getSheetNames();
    return sheetNames.contains(sheetName);
  }

  /// Gets data from the specified range with sheet validation
  Future<List<List<dynamic>>> getSheetDataWithValidation(String range) async {
    final sheetName = range.split('!')[0];
    final exists = await sheetExists(sheetName);
    
    if (!exists) {
      final availableSheets = await getSheetNames();
      throw GoogleSheetsException(
        'Sheet "$sheetName" not found. Available sheets: ${availableSheets.join(", ")}',
      );
    }
    
    return getSheetData(range);
  }
}
