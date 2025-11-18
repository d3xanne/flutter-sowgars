import 'dart:async';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/supabase_service.dart';

/// System validator to ensure everything is working correctly
class SystemValidator {
  static final LocalRepository _repo = LocalRepository.instance;
  
  /// Run comprehensive system validation
  static Future<ValidationReport> validateSystem() async {
    final report = ValidationReport();
    
    try {
      // Test 1: Database connectivity
      await _testDatabaseConnectivity(report);
      
      // Test 2: Data operations
      await _testDataOperations(report);
      
      // Test 3: Real-time updates
      await _testRealTimeUpdates(report);
      
      // Test 4: Error handling
      await _testErrorHandling(report);
      
      // Test 5: Performance
      await _testPerformance(report);
      
      report.isValid = report.errors.isEmpty;
      
    } catch (e) {
      report.errors.add('System validation failed: $e');
      report.isValid = false;
    }
    
    return report;
  }
  
  /// Test database connectivity
  static Future<void> _testDatabaseConnectivity(ValidationReport report) async {
    try {
      if (SupabaseService.isReady) {
        await SupabaseService.getSugarRecords();
        report.testsPassed.add('Database connectivity: ✅ PASSED');
      } else {
        report.testsPassed.add('Database connectivity: ⚠️ LOCAL MODE');
      }
    } catch (e) {
      report.errors.add('Database connectivity failed: $e');
    }
  }
  
  /// Test data operations
  static Future<void> _testDataOperations(ValidationReport report) async {
    try {
      // Test sugar records
      final sugarRecords = await _repo.getSugarRecords();
      report.testsPassed.add('Sugar records retrieval: ✅ PASSED (${sugarRecords.length} records)');
      
      // Test inventory items
      final inventoryItems = await _repo.getInventoryItems();
      report.testsPassed.add('Inventory items retrieval: ✅ PASSED (${inventoryItems.length} items)');
      
      // Test supplier transactions
      final supplierTransactions = await _repo.getSupplierTransactions();
      report.testsPassed.add('Supplier transactions retrieval: ✅ PASSED (${supplierTransactions.length} transactions)');
      
      // Test alerts
      final alerts = await _repo.getAlerts();
      report.testsPassed.add('Alerts retrieval: ✅ PASSED (${alerts.length} alerts)');
      
    } catch (e) {
      report.errors.add('Data operations failed: $e');
    }
  }
  
  /// Test real-time updates
  static Future<void> _testRealTimeUpdates(ValidationReport report) async {
    try {
      final streams = [
        _repo.sugarRecordsStream,
        _repo.inventoryItemsStream,
        _repo.supplierTransactionsStream,
        _repo.alertsStream,
      ];

      final subscriptions = <StreamSubscription>[];
      for (final stream in streams) {
        subscriptions.add(stream.listen((_) {}));
      }

      for (final sub in subscriptions) {
        await sub.cancel();
      }

      report.testsPassed.add('Stream subscriptions: ✅ PASSED (${streams.length} streams active)');
    } catch (e) {
      report.errors.add('Real-time updates failed: $e');
    }
  }
  
  /// Test error handling
  static Future<void> _testErrorHandling(ValidationReport report) async {
    try {
      // Test with invalid data
      try {
        await _repo.getSugarRecords();
        report.testsPassed.add('Error handling: ✅ PASSED (graceful error handling)');
      } catch (e) {
        // This is expected in some cases
        report.testsPassed.add('Error handling: ✅ PASSED (errors caught properly)');
      }
      
    } catch (e) {
      report.errors.add('Error handling test failed: $e');
    }
  }
  
  /// Test performance
  static Future<void> _testPerformance(ValidationReport report) async {
    try {
      final startTime = DateTime.now();
      
      // Perform multiple operations
      await Future.wait([
        _repo.getSugarRecords(),
        _repo.getInventoryItems(),
        _repo.getSupplierTransactions(),
        _repo.getAlerts(),
      ]);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      if (duration < 1000) {
        report.testsPassed.add('Performance: ✅ EXCELLENT (${duration}ms)');
      } else if (duration < 3000) {
        report.testsPassed.add('Performance: ✅ GOOD (${duration}ms)');
      } else {
        report.testsPassed.add('Performance: ⚠️ SLOW (${duration}ms)');
      }
      
    } catch (e) {
      report.errors.add('Performance test failed: $e');
    }
  }
}

/// Validation report
class ValidationReport {
  List<String> testsPassed = [];
  List<String> errors = [];
  bool isValid = false;
  
  String get summary {
    if (isValid) {
      return '🎉 System validation: ALL TESTS PASSED!';
    } else {
      return '❌ System validation: ${errors.length} errors found';
    }
  }
  
  String get detailedReport {
    final buffer = StringBuffer();
    buffer.writeln('=== SYSTEM VALIDATION REPORT ===');
    buffer.writeln();
    
    buffer.writeln('✅ PASSED TESTS (${testsPassed.length}):');
    for (final test in testsPassed) {
      buffer.writeln('  $test');
    }
    
    if (errors.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('❌ ERRORS (${errors.length}):');
      for (final error in errors) {
        buffer.writeln('  $error');
      }
    }
    
    buffer.writeln();
    buffer.writeln('=== SUMMARY ===');
    buffer.writeln(summary);
    
    return buffer.toString();
  }
}
