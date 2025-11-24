import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/google_sheets_service.dart';
import '../models/loading_return.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with TickerProviderStateMixin {
  final _googleSheetsService = GoogleSheetsService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _salesData = [];
  final DateTime _selectedDate = DateTime.now();
  
  // Tab controller for different chart views
  late TabController _tabController;

  // Chart data
  List<Map<String, dynamic>> _driverSalesData = [];
  List<Map<String, dynamic>> _productSalesData = [];
  List<Map<String, dynamic>> _dailySalesData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSalesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loadingsData = await _googleSheetsService.getSheetDataWithValidation('LOADINGS!A:Z');
      final returnsData = await _googleSheetsService.getSheetDataWithValidation('RETURNS!A:Z');

      final loadings = _processSheetData(loadingsData, 'loading');
      final returns = _processSheetData(returnsData, 'return');

      _salesData = _calculateSales(loadings, returns);
      _prepareChartData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load sales data: $e';
      });
    }
  }

  List<LoadingReturn> _processSheetData(List<List<dynamic>> sheetData, String type) {
    if (sheetData.isEmpty) return [];
    final headers = sheetData[0].map((h) => h.toString()).toList();
    final rows = sheetData.sublist(1);
    return rows.map((row) {
      return LoadingReturn.fromSheetsRow(row, headers);
    }).toList();
  }

  List<Map<String, dynamic>> _calculateSales(List<LoadingReturn> loadings, List<LoadingReturn> returns) {
    final salesData = <Map<String, dynamic>>[];
    final allDates = <DateTime>{};

    for (final loading in loadings) {
      allDates.add(DateTime(loading.date.year, loading.date.month, loading.date.day));
    }
    for (final returnData in returns) {
      allDates.add(DateTime(returnData.date.year, returnData.date.month, returnData.date.day));
    }

    for (final date in allDates) {
      final dateLoadings = loadings.where((l) =>
        DateTime(l.date.year, l.date.month, l.date.day) == date
      ).toList();

      final dateReturns = returns.where((r) =>
        DateTime(r.date.year, r.date.month, r.date.day) == date
      ).toList();

      final driverVehicleGroups = <String, Map<String, dynamic>>{};

      for (final loading in dateLoadings) {
        final key = '${loading.driverName}_${loading.vehicleNumber}';
        if (!driverVehicleGroups.containsKey(key)) {
          driverVehicleGroups[key] = {
            'date': date,
            'driverName': loading.driverName,
            'vehicleNumber': loading.vehicleNumber,
            'loadingQuantities': <String, int>{},
            'returnQuantities': <String, int>{},
            'salesQuantities': <String, int>{},
          };
        }
        driverVehicleGroups[key]!['loadingQuantities'].addAll(loading.productQuantities);
      }

      for (final returnData in dateReturns) {
        final key = '${returnData.driverName}_${returnData.vehicleNumber}';
        if (!driverVehicleGroups.containsKey(key)) {
          driverVehicleGroups[key] = {
            'date': date,
            'driverName': returnData.driverName,
            'vehicleNumber': returnData.vehicleNumber,
            'loadingQuantities': <String, int>{},
            'returnQuantities': <String, int>{},
            'salesQuantities': <String, int>{},
          };
        }
        driverVehicleGroups[key]!['returnQuantities'].addAll(returnData.productQuantities);
      }

      for (final group in driverVehicleGroups.values) {
        final loadingQuantities = group['loadingQuantities'] as Map<String, int>;
        final returnQuantities = group['returnQuantities'] as Map<String, int>;
        final salesQuantities = <String, int>{};

        final allProducts = <String>{};
        allProducts.addAll(loadingQuantities.keys);
        allProducts.addAll(returnQuantities.keys);

        for (final product in allProducts) {
          final loaded = loadingQuantities[product] ?? 0;
          final returned = returnQuantities[product] ?? 0;
          final sold = loaded - returned;
          if (sold > 0) {
            salesQuantities[product] = sold;
          }
        }
        group['salesQuantities'] = salesQuantities;
        salesData.add(group);
      }
    }
    salesData.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return salesData;
  }

  void _prepareChartData() {
    // Prepare driver sales data
    final driverTotals = <String, Map<String, int>>{};
    for (final sale in _salesData) {
      final driver = sale['driverName'] as String;
      if (!driverTotals.containsKey(driver)) {
        driverTotals[driver] = {};
      }
      final sales = sale['salesQuantities'] as Map<String, int>;
      for (final product in sales.keys) {
        driverTotals[driver]![product] = (driverTotals[driver]![product] ?? 0) + sales[product]!;
      }
    }

    _driverSalesData = driverTotals.entries.map((entry) {
      final totalSales = entry.value.values.fold(0, (sum, quantity) => sum + quantity);
      return {
        'driver': entry.key,
        'totalSales': totalSales,
        'productSales': entry.value,
      };
    }).toList()
      ..sort((a, b) => (b['totalSales'] as int).compareTo(a['totalSales'] as int));

    // Prepare product sales data
    final productTotals = <String, int>{};
    for (final sale in _salesData) {
      final sales = sale['salesQuantities'] as Map<String, int>;
      for (final product in sales.keys) {
        productTotals[product] = (productTotals[product] ?? 0) + sales[product]!;
      }
    }

    _productSalesData = productTotals.entries.map((entry) {
      return {
        'product': entry.key,
        'totalSales': entry.value,
      };
    }).toList()
      ..sort((a, b) => (b['totalSales'] as int).compareTo(a['totalSales'] as int));

    // Prepare daily sales data
    final dailyTotals = <DateTime, int>{};
    for (final sale in _salesData) {
      final date = sale['date'] as DateTime;
      final sales = sale['salesQuantities'] as Map<String, int>;
      final dailyTotal = sales.values.fold(0, (sum, quantity) => sum + quantity);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + dailyTotal;
    }

    _dailySalesData = dailyTotals.entries.map((entry) {
      return {
        'date': entry.key,
        'totalSales': entry.value,
      };
    }).toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSalesData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Driver Sales'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Product Sales'),
            Tab(icon: Icon(Icons.trending_up), text: 'Daily Trend'),
            Tab(icon: Icon(Icons.table_chart), text: 'Data Table'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _salesData.isEmpty
                  ? const Center(
                      child: Text(
                        'No sales data found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDriverSalesChart(),
                        _buildProductSalesChart(),
                        _buildDailySalesChart(),
                        _buildSalesDataTable(),
                      ],
                    ),
    );
  }

  Widget _buildDriverSalesChart() {
    if (_driverSalesData.isEmpty) {
      return const Center(child: Text('No driver sales data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Bar Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _driverSalesData.isNotEmpty 
                    ? _driverSalesData.first['totalSales'].toDouble() * 1.2 
                    : 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < _driverSalesData.length) {
                          final driver = _driverSalesData[value.toInt()]['driver'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              driver.length > 8 ? '${driver.substring(0, 8)}...' : driver,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _driverSalesData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['totalSales'].toDouble(),
                        color: Colors.green,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Driver Details
          ..._driverSalesData.map((driverData) {
            final driver = driverData['driver'] as String;
            final totalSales = driverData['totalSales'] as int;
            final productSales = driverData['productSales'] as Map<String, int>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(
                  driver,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Total Sales: $totalSales units'),
                children: [
                  ...productSales.entries.map((product) {
                    return ListTile(
                      title: Text(product.key),
                      trailing: Text(
                        '${product.value} units',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductSalesChart() {
    if (_productSalesData.isEmpty) {
      return const Center(child: Text('No product sales data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Pie Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _productSalesData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                    Colors.purple,
                    Colors.teal,
                  ];
                  
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: data['totalSales'].toDouble(),
                    title: '${data['totalSales']}',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Product Details
          ..._productSalesData.map((productData) {
            final product = productData['product'] as String;
            final totalSales = productData['totalSales'] as int;
            final percentage = _productSalesData.isNotEmpty 
                ? (totalSales / _productSalesData.fold(0, (sum, p) => sum + p['totalSales'])) * 100
                : 0.0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(product),
                subtitle: Text('${percentage.toStringAsFixed(1)}% of total sales'),
                trailing: Text(
                  '$totalSales units',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailySalesChart() {
    if (_dailySalesData.isEmpty) {
      return const Center(child: Text('No daily sales data available'));
    }

    // Take last 30 days for the chart
    final recentData = _dailySalesData.take(30).toList().reversed.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Line Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < recentData.length) {
                          final date = recentData[value.toInt()]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM d').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: recentData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value['totalSales'].toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Daily Details
          ...recentData.map((dailyData) {
            final date = dailyData['date'] as DateTime;
            final totalSales = dailyData['totalSales'] as int;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(DateFormat('EEEE, MMMM d, yyyy').format(date)),
                trailing: Text(
                  '$totalSales units',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSalesDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Date')),
            const DataColumn(label: Text('Driver')),
            const DataColumn(label: Text('Vehicle')),
            ...LoadingReturn.getAvailableProducts().map((product) => DataColumn(label: Text(product))),
            const DataColumn(label: Text('Total Sales')),
          ],
          rows: _salesData.map((saleData) {
            final sales = saleData['salesQuantities'] as Map<String, int>;
            final totalSales = sales.values.fold(0, (sum, quantity) => sum + quantity);
            
            return DataRow(
              cells: [
                DataCell(
                  Text(DateFormat('MMM d, y').format(saleData['date'])),
                ),
                DataCell(Text(saleData['driverName'])),
                DataCell(Text(saleData['vehicleNumber'])),
                ...LoadingReturn.getAvailableProducts().map((product) {
                  final quantity = sales[product] ?? 0;
                  return DataCell(
                    Text(quantity > 0 ? quantity.toString() : ''),
                  );
                }),
                DataCell(
                  Text(
                    totalSales.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
} 