import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/services/activity_tracker_service.dart';
import 'package:sample/services/data_export_platform.dart' as platform;
import 'package:sample/services/local_repository.dart';

class DataExportService {
  static final LocalRepository _repo = LocalRepository.instance;

  // Export selected data types to CSV files
  static Future<Map<String, String>> exportSelectedData({
    bool exportSugarRecords = true,
    bool exportInventory = true,
    bool exportSuppliers = true,
    bool exportAlerts = false,
  }) async {
    try {
      if (kIsWeb) {
        // For web platform, return CSV content as strings
        final results = <String, String>{};
        int totalRecords = 0;

        // Export Sugar Records
        if (exportSugarRecords) {
          final sugarRecords = await _repo.getSugarRecords();
          final sugarCsv = _exportSugarRecordsToCSV(sugarRecords);
          results['sugar_records'] = sugarCsv;
          totalRecords += sugarRecords.length;
        }

        // Export Inventory Items
        if (exportInventory) {
          final inventoryItems = await _repo.getInventoryItems();
          final inventoryCsv = _exportInventoryItemsToCSV(inventoryItems);
          results['inventory_items'] = inventoryCsv;
          totalRecords += inventoryItems.length;
        }

        // Export Supplier Transactions
        if (exportSuppliers) {
          final supplierTransactions = await _repo.getSupplierTransactions();
          final supplierCsv = _exportSupplierTransactionsToCSV(supplierTransactions);
          results['supplier_transactions'] = supplierCsv;
          totalRecords += supplierTransactions.length;
        }

        // Export Alerts
        if (exportAlerts) {
          final alerts = await _repo.getAlerts();
          final alertsCsv = _exportAlertsToCSV(alerts);
          results['alerts'] = alertsCsv;
          totalRecords += alerts.length;
        }

        // Create a summary
        final summary = _createExportSummary(
          exportSugarRecords ? (await _repo.getSugarRecords()).length : 0,
          exportInventory ? (await _repo.getInventoryItems()).length : 0,
          exportSuppliers ? (await _repo.getSupplierTransactions()).length : 0,
        );
        results['summary'] = summary;

        // Track activity
        ActivityTrackerService().trackDataExported('Selected Data', totalRecords);

        return results;
      } else {
        // For mobile platforms, use file system
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final exportDir = Directory('${directory.path}/hacienda_export_$timestamp');
        
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }

        final results = <String, String>{};

        // Export Sugar Records
        if (exportSugarRecords) {
          final sugarRecords = await _repo.getSugarRecords();
          final sugarCsv = _exportSugarRecordsToCSV(sugarRecords);
          final sugarFile = File('${exportDir.path}/sugar_records.csv');
          await sugarFile.writeAsString(sugarCsv);
          results['sugar_records'] = sugarFile.path;
        }

        // Export Inventory Items
        if (exportInventory) {
          final inventoryItems = await _repo.getInventoryItems();
          final inventoryCsv = _exportInventoryItemsToCSV(inventoryItems);
          final inventoryFile = File('${exportDir.path}/inventory_items.csv');
          await inventoryFile.writeAsString(inventoryCsv);
          results['inventory_items'] = inventoryFile.path;
        }

        // Export Supplier Transactions
        if (exportSuppliers) {
          final supplierTransactions = await _repo.getSupplierTransactions();
          final supplierCsv = _exportSupplierTransactionsToCSV(supplierTransactions);
          final supplierFile = File('${exportDir.path}/supplier_transactions.csv');
          await supplierFile.writeAsString(supplierCsv);
          results['supplier_transactions'] = supplierFile.path;
        }

        // Export Alerts
        if (exportAlerts) {
          final alerts = await _repo.getAlerts();
          final alertsCsv = _exportAlertsToCSV(alerts);
          final alertsFile = File('${exportDir.path}/alerts.csv');
          await alertsFile.writeAsString(alertsCsv);
          results['alerts'] = alertsFile.path;
        }

        // Create a summary file
        final summary = _createExportSummary(
          exportSugarRecords ? (await _repo.getSugarRecords()).length : 0,
          exportInventory ? (await _repo.getInventoryItems()).length : 0,
          exportSuppliers ? (await _repo.getSupplierTransactions()).length : 0,
        );
        final summaryFile = File('${exportDir.path}/export_summary.txt');
        await summaryFile.writeAsString(summary);
        results['summary'] = summaryFile.path;
        results['export_directory'] = exportDir.path;

        return results;
      }
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Export all data to CSV files (backward compatibility)
  static Future<Map<String, String>> exportAllData() async {
    return exportSelectedData(
      exportSugarRecords: true,
      exportInventory: true,
      exportSuppliers: true,
      exportAlerts: false,
    );
  }

  // Share exported files on mobile
  static Future<void> shareExportedFiles(BuildContext context, Map<String, String> results) async {
    if (kIsWeb) {
      // For web, files are already downloaded
      return;
    }

    try {
      final files = <XFile>[];
      
      // Add all exported CSV files
      for (final entry in results.entries) {
        if (entry.key != 'summary' && entry.key != 'export_directory') {
          final file = File(entry.value);
          if (await file.exists()) {
            files.add(XFile(file.path));
          }
        }
      }

      if (files.isEmpty) {
        throw Exception('No files to share');
      }

      // Share files using share_plus
      if (files.length == 1) {
        await Share.shareXFiles([files.first], text: 'Hacienda Elizabeth Data Export');
      } else {
        await Share.shareXFiles(files, text: 'Hacienda Elizabeth Data Export');
      }
    } catch (e) {
      throw Exception('Failed to share files: $e');
    }
  }

  // Export Sugar Records to CSV
  static String _exportSugarRecordsToCSV(List<SugarRecord> records) {
    final List<List<dynamic>> csvData = [
      ['ID', 'Date', 'Variety', 'Soil Test', 'Fertilizer', 'Height (cm)', 'Notes']
    ];

    for (final record in records) {
      csvData.add([
        record.id,
        record.date,
        record.variety,
        record.soilTest,
        record.fertilizer,
        record.heightCm,
        record.notes,
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  // Export Inventory Items to CSV
  static String _exportInventoryItemsToCSV(List<InventoryItem> items) {
    final List<List<dynamic>> csvData = [
      ['ID', 'Name', 'Category', 'Quantity', 'Unit', 'Last Updated']
    ];

    for (final item in items) {
      csvData.add([
        item.id,
        item.name,
        item.category,
        item.quantity,
        item.unit,
        item.lastUpdated,
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  // Export Supplier Transactions to CSV
  static String _exportSupplierTransactionsToCSV(List<SupplierTransaction> transactions) {
    final List<List<dynamic>> csvData = [
      ['ID', 'Supplier Name', 'Item Name', 'Quantity', 'Unit', 'Amount', 'Date', 'Notes']
    ];

    for (final transaction in transactions) {
      csvData.add([
        transaction.id,
        transaction.supplierName,
        transaction.itemName,
        transaction.quantity,
        transaction.unit,
        transaction.amount,
        transaction.date,
        transaction.notes,
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  // Create export summary
  static String _createExportSummary(int sugarCount, int inventoryCount, int supplierCount) {
    final timestamp = DateTime.now().toString();
    return '''
Hacienda Elizabeth - Data Export Summary
Generated: $timestamp

Export Details:
- Sugar Records: $sugarCount entries
- Inventory Items: $inventoryCount entries  
- Supplier Transactions: $supplierCount entries

Total Records: ${sugarCount + inventoryCount + supplierCount}

Files Exported:
- sugar_records.csv
- inventory_items.csv
- supplier_transactions.csv

This export contains all your farming data as of $timestamp.
You can import this data back into the app using the Import Data feature.
''';
  }

  // Additional methods for data export widget
  static Future<void> exportSugarRecords() async {
    try {
      final records = await _repo.getSugarRecords();
      final csvContent = _exportSugarRecordsToCSV(records);
      
      if (kIsWeb) {
        _downloadCSV('sugar_records', csvContent);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/sugar_records.csv');
        await file.writeAsString(csvContent);
      }
    } catch (e) {
      throw Exception('Failed to export sugar records: $e');
    }
  }

  static Future<void> exportInventoryData() async {
    try {
      final items = await _repo.getInventoryItems();
      final csvContent = _exportInventoryItemsToCSV(items);
      
      if (kIsWeb) {
        _downloadCSV('inventory_items', csvContent);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/inventory_items.csv');
        await file.writeAsString(csvContent);
      }
    } catch (e) {
      throw Exception('Failed to export inventory: $e');
    }
  }

  static Future<void> exportSupplierData() async {
    try {
      final transactions = await _repo.getSupplierTransactions();
      final csvContent = _exportSupplierTransactionsToCSV(transactions);
      
      if (kIsWeb) {
        _downloadCSV('supplier_transactions', csvContent);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/supplier_transactions.csv');
        await file.writeAsString(csvContent);
      }
    } catch (e) {
      throw Exception('Failed to export suppliers: $e');
    }
  }

  static Future<void> exportAlertData() async {
    try {
      final alerts = await _repo.getAlerts();
      final csvContent = _exportAlertsToCSV(alerts);
      
      if (kIsWeb) {
        _downloadCSV('alerts', csvContent);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/alerts.csv');
        await file.writeAsString(csvContent);
      }
    } catch (e) {
      throw Exception('Failed to export alerts: $e');
    }
  }

  static Future<void> generateComprehensiveReport() async {
    try {
      final sugarRecords = await _repo.getSugarRecords();
      final inventoryItems = await _repo.getInventoryItems();
      final supplierTransactions = await _repo.getSupplierTransactions();
      final alerts = await _repo.getAlerts();

      final report = _generateComprehensiveReport(
        sugarRecords,
        inventoryItems,
        supplierTransactions,
        alerts,
      );

      if (kIsWeb) {
        _downloadCSV('comprehensive_report', report);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/comprehensive_report.txt');
        await file.writeAsString(report);
      }
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  // Export alerts to CSV
  static String _exportAlertsToCSV(List<dynamic> alerts) {
    final List<List<dynamic>> csvData = [
      ['ID', 'Title', 'Message', 'Severity', 'Read', 'Timestamp']
    ];

    for (final alert in alerts) {
      csvData.add([
        alert.id ?? '',
        alert.title ?? '',
        alert.message ?? '',
        alert.severity ?? '',
        alert.read ?? false,
        alert.timestamp?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  // Generate comprehensive report
  static String _generateComprehensiveReport(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<SupplierTransaction> supplierTransactions,
    List<dynamic> alerts,
  ) {
    final timestamp = DateTime.now().toString();
    final totalSpending = supplierTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final averageGrowth = sugarRecords.isNotEmpty 
        ? sugarRecords.map((r) => r.heightCm).reduce((a, b) => a + b) / sugarRecords.length 
        : 0.0;
    final lowStockItems = inventoryItems.where((item) => item.quantity <= 10).length;
    final unreadAlerts = alerts.where((a) => a.read == false).length;

    return '''
HACIENDA ELIZABETH - COMPREHENSIVE FARM REPORT
Generated: $timestamp

=== EXECUTIVE SUMMARY ===
Total Sugar Records: ${sugarRecords.length}
Total Inventory Items: ${inventoryItems.length}
Total Supplier Transactions: ${supplierTransactions.length}
Total Alerts: ${alerts.length}

=== FINANCIAL OVERVIEW ===
Total Spending: ₱${totalSpending.toStringAsFixed(2)}
Average Transaction: ₱${supplierTransactions.isNotEmpty ? (totalSpending / supplierTransactions.length).toStringAsFixed(2) : '0.00'}

=== GROWTH ANALYSIS ===
Average Growth Height: ${averageGrowth.toStringAsFixed(1)} cm
Total Growth Records: ${sugarRecords.length}
Growth Trend: ${sugarRecords.length > 1 ? 'Analyzing...' : 'Insufficient data'}

=== INVENTORY STATUS ===
Total Items: ${inventoryItems.length}
Low Stock Items: $lowStockItems
Low Stock Percentage: ${inventoryItems.isNotEmpty ? ((lowStockItems / inventoryItems.length) * 100).toStringAsFixed(1) : '0.0'}%

=== ALERT SUMMARY ===
Total Alerts: ${alerts.length}
Unread Alerts: $unreadAlerts
Alert Response Rate: ${alerts.isNotEmpty ? (((alerts.length - unreadAlerts) / alerts.length) * 100).toStringAsFixed(1) : '0.0'}%

=== RECOMMENDATIONS ===
${_generateRecommendations(sugarRecords, inventoryItems, supplierTransactions, alerts)}

=== DETAILED BREAKDOWN ===
${_createDetailedBreakdown(sugarRecords, inventoryItems, supplierTransactions, alerts)}

Report generated by Hacienda Elizabeth Agricultural Management System
For questions or support, contact your system administrator.
''';
  }

  static String _generateRecommendations(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<SupplierTransaction> supplierTransactions,
    List<dynamic> alerts,
  ) {
    final recommendations = <String>[];

    if (sugarRecords.isNotEmpty) {
      final avgGrowth = sugarRecords.map((r) => r.heightCm).reduce((a, b) => a + b) / sugarRecords.length;
      if (avgGrowth < 80) {
        recommendations.add('• Consider improving fertilization practices - average growth is below optimal');
      }
    }

    final lowStockItems = inventoryItems.where((item) => item.quantity <= 10).length;
    if (lowStockItems > inventoryItems.length * 0.3) {
      recommendations.add('• High number of low stock items - consider bulk ordering');
    }

    final unreadAlerts = alerts.where((a) => a.read == false).length;
    if (unreadAlerts > 5) {
      recommendations.add('• Multiple unread alerts require attention');
    }

    if (supplierTransactions.isNotEmpty) {
      final totalSpent = supplierTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      if (totalSpent > 100000) {
        recommendations.add('• High spending detected - review supplier contracts for better rates');
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('• System is running smoothly - continue current practices');
    }

    return recommendations.join('\n');
  }

  static String _createDetailedBreakdown(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<SupplierTransaction> supplierTransactions,
    List<dynamic> alerts,
  ) {
    final buffer = StringBuffer();

    // Sugar Records breakdown
    if (sugarRecords.isNotEmpty) {
      buffer.writeln('SUGAR RECORDS:');
      final varieties = <String, int>{};
      for (final record in sugarRecords) {
        varieties[record.variety] = (varieties[record.variety] ?? 0) + 1;
      }
      for (final entry in varieties.entries) {
        buffer.writeln('  - ${entry.key}: ${entry.value} records');
      }
      buffer.writeln();
    }

    // Inventory breakdown
    if (inventoryItems.isNotEmpty) {
      buffer.writeln('INVENTORY CATEGORIES:');
      final categories = <String, int>{};
      for (final item in inventoryItems) {
        categories[item.category] = (categories[item.category] ?? 0) + 1;
      }
      for (final entry in categories.entries) {
        buffer.writeln('  - ${entry.key}: ${entry.value} items');
      }
      buffer.writeln();
    }

    // Supplier breakdown
    if (supplierTransactions.isNotEmpty) {
      buffer.writeln('TOP SUPPLIERS BY SPENDING:');
      final supplierSpending = <String, double>{};
      for (final tx in supplierTransactions) {
        supplierSpending[tx.supplierName] = (supplierSpending[tx.supplierName] ?? 0) + tx.amount;
      }
      final sortedSuppliers = supplierSpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (final entry in sortedSuppliers.take(5)) {
        buffer.writeln('  - ${entry.key}: ₱${entry.value.toStringAsFixed(2)}');
      }
    }

    return buffer.toString();
  }

  // Download CSV file for web
  static void _downloadCSV(String filename, String csvContent) =>
      platform.downloadCSV(filename, csvContent);

  // Show export success dialog
  static void showExportSuccessDialog(BuildContext context, Map<String, String> results) {
    if (kIsWeb) {
      // For web, show download options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your data has been exported successfully!'),
              const SizedBox(height: 16),
              const Text('Click the buttons below to download your data:'),
              const SizedBox(height: 16),
              ...results.entries
                  .where((entry) => entry.key != 'summary')
                  .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadCSV(entry.key, entry.value),
                      icon: const Icon(Icons.download),
                      label: Text('Download ${entry.key.replaceAll('_', ' ')}.csv'),
                    ),
                  )),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      // For mobile, show file paths and share option
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Successful'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your data has been exported successfully!'),
                const SizedBox(height: 16),
                const Text('Exported files:'),
                const SizedBox(height: 8),
                ...results.entries
                    .where((entry) => entry.key != 'summary' && entry.key != 'export_directory')
                    .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${entry.key.replaceAll('_', ' ')}.csv'),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Text(
                  'Files saved to:',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  results['export_directory']?.replaceAll(RegExp(r'/[^/]*$'), '') ?? 
                  results['summary']?.replaceAll(RegExp(r'/[^/]*$'), '') ?? 
                  'Unknown location',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await shareExportedFiles(context, results);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Share failed: $e'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Show import success dialog
  static void showImportSuccessDialog(BuildContext context, Map<String, int> results) {
    final totalImported = results.values.fold(0, (sum, count) => sum + count);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully imported $totalImported records!'),
            const SizedBox(height: 16),
            ...results.entries.map((entry) => Text(
              '• ${entry.key.replaceAll('_', ' ')}: ${entry.value} records',
            )),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Import data from CSV files
  static Future<Map<String, int>> importData() async {
    try {
      // Pick CSV files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No files selected');
      }

      final importResults = <String, int>{};

      for (final file in result.files) {
        if (file.bytes != null) {
          final csvContent = utf8.decode(file.bytes!);
          final fileName = file.name.toLowerCase();

          if (fileName.contains('sugar')) {
            final count = await _importSugarRecords(csvContent);
            importResults['sugar_records'] = count;
          } else if (fileName.contains('inventory')) {
            final count = await _importInventoryItems(csvContent);
            importResults['inventory_items'] = count;
          } else if (fileName.contains('supplier')) {
            final count = await _importSupplierTransactions(csvContent);
            importResults['supplier_transactions'] = count;
          }
        }
      }

      return importResults;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Import Sugar Records from CSV
  static Future<int> _importSugarRecords(String csvContent) async {
    final csvData = const CsvToListConverter().convert(csvContent);
    if (csvData.isEmpty) return 0;

    // Skip header row
    final dataRows = csvData.skip(1).toList();
    final records = <SugarRecord>[];

    for (final row in dataRows) {
      if (row.length >= 7) {
        try {
          final record = SugarRecord(
            id: row[0]?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
            date: row[1]?.toString() ?? DateTime.now().toIso8601String().split('T')[0],
            variety: row[2]?.toString() ?? 'Unknown',
            soilTest: row[3]?.toString() ?? 'Not tested',
            fertilizer: row[4]?.toString() ?? 'None',
            heightCm: int.tryParse(row[5]?.toString() ?? '0') ?? 0,
            notes: row[6]?.toString() ?? '',
          );
          records.add(record);
        } catch (e) {
          print('Error parsing sugar record: $e');
        }
      }
    }

    if (records.isNotEmpty) {
      final existingRecords = await _repo.getSugarRecords();
      existingRecords.addAll(records);
      await _repo.saveSugarRecords(existingRecords);
    }

    return records.length;
  }

  // Import Inventory Items from CSV
  static Future<int> _importInventoryItems(String csvContent) async {
    final csvData = const CsvToListConverter().convert(csvContent);
    if (csvData.isEmpty) return 0;

    final dataRows = csvData.skip(1).toList();
    final items = <InventoryItem>[];

    for (final row in dataRows) {
      if (row.length >= 6) {
        try {
          final item = InventoryItem(
            id: row[0]?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
            name: row[1]?.toString() ?? 'Unknown Item',
            category: row[2]?.toString() ?? 'General',
            quantity: int.tryParse(row[3]?.toString() ?? '0') ?? 0,
            unit: row[4]?.toString() ?? 'pieces',
            lastUpdated: row[5]?.toString() ?? DateTime.now().toIso8601String().split('T')[0],
          );
          items.add(item);
        } catch (e) {
          print('Error parsing inventory item: $e');
        }
      }
    }

    if (items.isNotEmpty) {
      final existingItems = await _repo.getInventoryItems();
      existingItems.addAll(items);
      await _repo.saveInventoryItems(existingItems);
    }

    return items.length;
  }

  // Import Supplier Transactions from CSV
  static Future<int> _importSupplierTransactions(String csvContent) async {
    final csvData = const CsvToListConverter().convert(csvContent);
    if (csvData.isEmpty) return 0;

    final dataRows = csvData.skip(1).toList();
    final transactions = <SupplierTransaction>[];

    for (final row in dataRows) {
      if (row.length >= 8) {
        try {
          final transaction = SupplierTransaction(
            id: row[0]?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
            supplierName: row[1]?.toString() ?? 'Unknown Supplier',
            itemName: row[2]?.toString() ?? 'Unknown Item',
            quantity: int.tryParse(row[3]?.toString() ?? '0') ?? 0,
            unit: row[4]?.toString() ?? 'pieces',
            amount: double.tryParse(row[5]?.toString() ?? '0') ?? 0.0,
            date: row[6]?.toString() ?? DateTime.now().toIso8601String().split('T')[0],
            notes: row[7]?.toString() ?? '',
          );
          transactions.add(transaction);
        } catch (e) {
          print('Error parsing supplier transaction: $e');
        }
      }
    }

    if (transactions.isNotEmpty) {
      final existingTransactions = await _repo.getSupplierTransactions();
      existingTransactions.addAll(transactions);
      await _repo.saveSupplierTransactions(existingTransactions);
    }

    return transactions.length;
  }

  // Legacy methods for compatibility
  static Future<Map<String, String>> exportInventory() async {
    try {
      final items = await _repo.getInventoryItems();
      final csvContent = _exportInventoryItemsToCSV(items);
      
      if (kIsWeb) {
        return {'inventory': csvContent};
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/inventory.csv');
        await file.writeAsString(csvContent);
        return {'inventory': file.path};
      }
    } catch (e) {
      throw Exception('Failed to export inventory: $e');
    }
  }

  static Future<Map<String, String>> exportSuppliers() async {
    try {
      final transactions = await _repo.getSupplierTransactions();
      final csvContent = _exportSupplierTransactionsToCSV(transactions);
      
      if (kIsWeb) {
        return {'suppliers': csvContent};
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/suppliers.csv');
        await file.writeAsString(csvContent);
        return {'suppliers': file.path};
      }
    } catch (e) {
      throw Exception('Failed to export suppliers: $e');
    }
  }
}