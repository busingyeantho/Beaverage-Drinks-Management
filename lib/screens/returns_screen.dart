import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/google_sheets_service.dart';
import '../models/loading_return.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  _ReturnsScreenState createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _googleSheetsService = GoogleSheetsService();

  // Form data
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Product quantities for returns
  final Map<String, int> _productQuantities = {
    'B-Steady 24x200ml': 0,
    'B-Steady Pieces': 0,
    'B-Steady 12x200ml': 0,
    'Jim Pombe 24x200ml': 0,
    'Jim Pombe 12x200ml': 0,
    'Jim Pombe Pieces': 0,
  };

  // App state
  bool _isLoading = true;
  String? _errorMessage;
  List<LoadingReturn> _returnsData = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _googleSheetsService.getSheetDataWithValidation(
        'RETURNS!A:Z',
      );

      if (data.isNotEmpty) {
        final headers = data[0].map((h) => h.toString()).toList();
        final rows = data.sublist(1);

        _returnsData = rows.map((row) {
          return LoadingReturn.fromSheetsRow(row, headers);
        }).toList();
      } else {
        // If sheet is empty, set up headers
        await _setupSheetHeaders();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  Future<void> _setupSheetHeaders() async {
    try {
      final headers = LoadingReturn.getHeaders();
      await _googleSheetsService.appendRow('RETURNS!A:Z', headers);
    } catch (e) {
      print('Failed to setup headers: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final returnsData = LoadingReturn(
          date: _selectedDate,
          driverName: _driverNameController.text,
          vehicleNumber: _vehicleNumberController.text,
          productQuantities: Map.from(_productQuantities)
            ..removeWhere((_, value) => value == 0),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        // Convert to row for Google Sheets
        final values = returnsData.toSheetsRow();

        // Append to the RETURNS sheet
        await _googleSheetsService.appendRow('RETURNS!A:Z', values);

        // Refresh the data
        await _loadExistingData();

        // Reset the form
        _formKey.currentState!.reset();
        _productQuantities.updateAll((_, __) => 0);
        _selectedDate = DateTime.now();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Returns data submitted successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to submit form: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Evening Returns'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'View Returns'),
              Tab(icon: Icon(Icons.add), text: 'Add Returns'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // View Returns Tab
            _buildReturnsList(),
            // Add Returns Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildAddReturnsForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_returnsData.isEmpty) {
      return const Center(
        child: Text(
          'No returns data found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // Get all unique product names
    final productNames = LoadingReturn.getAllProductNames(_returnsData).toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Date')),
            const DataColumn(label: Text('Driver')),
            const DataColumn(label: Text('Vehicle')),
            ...productNames.map((name) => DataColumn(label: Text(name))),
            const DataColumn(label: Text('Notes')),
          ],
          rows: _returnsData.map((returnsData) {
            return DataRow(
              cells: [
                DataCell(
                  Text(DateFormat('MMM d, y').format(returnsData.date)),
                ),
                DataCell(Text(returnsData.driverName)),
                DataCell(Text(returnsData.vehicleNumber)),
                ...productNames.map((name) {
                  final quantity = returnsData.productQuantities[name] ?? 0;
                  return DataCell(
                    Text(quantity > 0 ? quantity.toString() : ''),
                  );
                }),
                DataCell(Text(returnsData.notes ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddReturnsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date Picker
          const Text(
            'Select Return Date:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can select any date (past or future) for when the returns actually occurred',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          InputDatePickerFormField(
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: _selectedDate,
            fieldLabelText: 'Return Date',
            onDateSubmitted: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Selected Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver Name
          TextFormField(
            controller: _driverNameController,
            decoration: const InputDecoration(
              labelText: 'Driver Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter driver name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Vehicle Number
          TextFormField(
            controller: _vehicleNumberController,
            decoration: const InputDecoration(
              labelText: 'Vehicle Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_shipping),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter vehicle number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Product Quantities
          const Text(
            'Products Returned:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ..._productQuantities.keys.map((productName) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text(productName)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _productQuantities[productName]?.toString() ?? '0',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (value) {
                        final quantity = int.tryParse(value) ?? 0;
                        setState(() {
                          _productQuantities[productName] = quantity;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),

          // Notes
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),

          // Submit Button
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Submit Returns Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          // Error Message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _vehicleNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 