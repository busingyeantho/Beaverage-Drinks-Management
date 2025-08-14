import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FirebaseSheetsService {
  final String functionsBaseUrl;
  final String? authToken;

  FirebaseSheetsService({required this.functionsBaseUrl, this.authToken});

  // Helper method to add authorization header
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // Get sheet names
  Future<List<String>> getSheetNames(String spreadsheetId) async {
    try {
      final uri = Uri.parse('$functionsBaseUrl/getSheetNames')
          .replace(queryParameters: {'spreadsheetId': spreadsheetId});
      
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['sheetNames']);
      } else {
        throw Exception('Failed to load sheet names: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getSheetNames: $e');
      rethrow;
    }
  }

  // Get sheet data
  Future<List<List<dynamic>>> getSheetData(
    String spreadsheetId, 
    String range,
  ) async {
    try {
      final uri = Uri.parse('$functionsBaseUrl/getSheetData').replace(
        queryParameters: {
          'spreadsheetId': spreadsheetId,
          'range': range,
        },
      );

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<List<dynamic>>.from(
          data['data'].map((x) => List<dynamic>.from(x)),
        );
      } else {
        throw Exception('Failed to load sheet data: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getSheetData: $e');
      rethrow;
    }
  }
}
