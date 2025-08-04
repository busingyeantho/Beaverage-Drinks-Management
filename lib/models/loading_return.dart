import 'package:intl/intl.dart';

class LoadingReturn {
  final DateTime date;
  final String driverName;
  final String vehicleNumber;
  final Map<String, int> productQuantities;
  final String? notes;

  LoadingReturn({
    required this.date,
    required this.driverName,
    required this.vehicleNumber,
    required this.productQuantities,
    this.notes,
  });

  // Get all available product names (static list for consistency)
  static List<String> getAvailableProducts() {
    return [
      'B-Steady 24x200ml',
      'B-Steady Pieces',
      'B-Steady 12x200ml',
      'Jim Pombe 24x200ml',
      'Jim Pombe 12x200ml',
      'Jim Pombe Pieces',
    ];
  }

  // Get column headers for Google Sheets
  static List<String> getHeaders() {
    return [
      'Date',
      'Driver Name',
      'Vehicle Number',
      ...getAvailableProducts(),
      'Notes',
    ];
  }

  // Convert a LoadingReturn to a list of values for Google Sheets
  List<String> toSheetsRow() {
    final headers = getHeaders();
    final values = <String>[];
    
    for (final header in headers) {
      switch (header) {
        case 'Date':
          values.add(DateFormat('yyyy-MM-dd').format(date));
          break;
        case 'Driver Name':
          values.add(driverName);
          break;
        case 'Vehicle Number':
          values.add(vehicleNumber);
          break;
        case 'Notes':
          values.add(notes ?? '');
          break;
        default:
          // This is a product column
          values.add((productQuantities[header] ?? 0).toString());
          break;
      }
    }
    
    return values;
  }

  // Create a LoadingReturn from a Google Sheets row
  factory LoadingReturn.fromSheetsRow(List<dynamic> row, List<String> headers) {
    if (row.length < 3) {
      throw Exception('Invalid row data: insufficient columns');
    }

    // Extract basic fields
    final dateStr = row[0]?.toString() ?? '';
    final driverName = row[1]?.toString() ?? '';
    final vehicleNumber = row[2]?.toString() ?? '';

    // Extract product quantities
    final productQuantities = <String, int>{};
    final availableProducts = getAvailableProducts();
    
    for (int i = 0; i < availableProducts.length; i++) {
      final productIndex = 3 + i; // Products start after Date, Driver, Vehicle
      if (productIndex < row.length) {
        final quantity = int.tryParse(row[productIndex]?.toString() ?? '0') ?? 0;
        if (quantity > 0) {
          productQuantities[availableProducts[i]] = quantity;
        }
      }
    }

    // Extract notes (last column)
    final notesIndex = headers.length - 1;
    final notes = notesIndex < row.length ? row[notesIndex]?.toString() : '';

    // Parse date with multiple format support
    DateTime parseDate(String dateStr) {
      if (dateStr.isEmpty) return DateTime.now();
      
      // Try different date formats
      final formats = [
        'yyyy-MM-dd',      // 2024-01-15
        'dd/MM/yyyy',      // 15/01/2024
        'MM/dd/yyyy',      // 01/15/2024
        'dd-MM-yyyy',      // 15-01-2024
        'MM-dd-yyyy',      // 01-15-2024
        'yyyy/MM/dd',      // 2024/01/15
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateStr.trim());
        } catch (e) {
          // Continue to next format
        }
      }

      // If all formats fail, try to parse as DateTime object (from Google Sheets)
      try {
        if (dateStr.contains('T') || dateStr.contains('Z')) {
          return DateTime.parse(dateStr);
        }
      } catch (e) {
        // Continue to fallback
      }

      // Fallback to current date
      print('Warning: Could not parse date "$dateStr", using current date');
      return DateTime.now();
    }

    return LoadingReturn(
      date: parseDate(dateStr),
      driverName: driverName,
      vehicleNumber: vehicleNumber,
      productQuantities: productQuantities,
      notes: notes?.isNotEmpty == true ? notes : null,
    );
  }

  // Helper method to get all product names from multiple loading returns
  static Set<String> getAllProductNames(List<LoadingReturn> loadingReturns) {
    final productNames = <String>{};
    for (final loadingReturn in loadingReturns) {
      productNames.addAll(loadingReturn.productQuantities.keys);
    }
    return productNames;
  }
}
