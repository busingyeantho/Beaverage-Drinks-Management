import 'package:john_pombe/services/google_sheets_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    print('Loading environment variables...');
    await dotenv.load(fileName: ".env");
    
    print('Initializing Google Sheets Service...');
    final sheetsService = GoogleSheetsService();
    
    print('Getting sheet names...');
    final sheetNames = await sheetsService.getSheetNames();
    print('Available sheets: $sheetNames');
    
    if (sheetNames.isNotEmpty) {
      print('\nReading data from first sheet: ${sheetNames[0]}');
      final data = await sheetsService.getSheetData('${sheetNames[0]}!A1:B2');
      print('Data from sheet:');
      print(data);
    }
    
    print('\nTest completed successfully!');
  } catch (e, stackTrace) {
    print('Error occurred:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
  }
}
