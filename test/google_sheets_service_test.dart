import 'package:flutter_test/flutter_test.dart';
import 'package:john_pombe/services/google_sheets_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late GoogleSheetsService sheetsService;
  
  setUpAll(() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize the service
    sheetsService = GoogleSheetsService();
  });

  test('Test getSheetData', () async {
    // Test reading data from the sheet
    final data = await sheetsService.getSheetData('LOADING AND RETURNS!A1:Z1000');
    expect(data, isNotNull);
    expect(data, isA<List<List<dynamic>>>());
    
    // Print the first few rows for debugging
    print('First 5 rows:');
    for (var i = 0; i < data.length && i < 5; i++) {
      print('Row ${i + 1}: ${data[i]}');
    }
  });

  test('Test append and read row', () async {
    // Test data to append
    final testData = [
      DateTime.now().toIso8601String(),
      'Test Entry',
      'Test Description',
      '100',
      'KG',
      'Test User'
    ];
    
    // Append the test data
    await sheetsService.appendRow('LOADING AND RETURNS!A:F', testData);
    
    // Read the last few rows to verify
    final data = await sheetsService.getSheetData('LOADING AND RETURNS!A2:F');
    expect(data, isNotEmpty);
    
    // The last row should be our test data
    final lastRow = data.last;
    expect(lastRow, isNotNull);
    
    // Print for verification
    print('Appended row: $lastRow');
  });

  test('Test getSheetNames', () async {
    final sheetNames = await sheetsService.getSheetNames();
    expect(sheetNames, isNotNull);
    expect(sheetNames, isA<List<String>>());
    expect(sheetNames.isNotEmpty, true);
    
    print('Sheet names: $sheetNames');
  });
}
