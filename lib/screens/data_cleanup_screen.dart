import 'package:flutter/material.dart';
import 'package:sample/services/complete_data_manager.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/theme/app_theme.dart';
import 'package:sample/constants/app_icons.dart';

class DataCleanupScreen extends StatefulWidget {
  const DataCleanupScreen({Key? key}) : super(key: key);

  @override
  State<DataCleanupScreen> createState() => _DataCleanupScreenState();
}

class _DataCleanupScreenState extends State<DataCleanupScreen> {
  bool _isCleaning = false;
  String _currentOperation = '';
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Cleanup'),
        backgroundColor: AppTheme.getPrimaryColor(context),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.warning,
                      color: Colors.orange.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warning: Data Cleanup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This will permanently delete all data from the system and database. This action cannot be undone.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Progress Section
            if (_isCleaning) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cleaning in Progress...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.getPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentOperation,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_progress * 100).toInt()}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Cleanup Options
            Text(
              'Cleanup Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Local Data Cleanup
            _buildCleanupCard(
              title: 'Clear Local Data',
              description: 'Remove all data stored locally on this device',
              icon: AppIcons.database,
              color: Colors.blue,
              onTap: _clearLocalData,
            ),
            
            const SizedBox(height: 12),
            
            // Database Cleanup
            _buildCleanupCard(
              title: 'Clear Database',
              description: 'Remove all data from Supabase database',
              icon: AppIcons.sync,
              color: Colors.red,
              onTap: _clearDatabase,
            ),
            
            const SizedBox(height: 12),
            
            // Complete Cleanup
            _buildCleanupCard(
              title: 'Complete Cleanup',
              description: 'Remove all data from both local storage and database',
              icon: AppIcons.delete,
              color: Colors.red.shade700,
              onTap: _completeCleanup,
            ),
            
            const SizedBox(height: 12),
            
            // Reset to Clean Demo
            _buildCleanupCard(
              title: 'Reset to Clean Demo',
              description: 'Clear all data and add minimal clean demo data',
              icon: AppIcons.refresh,
              color: Colors.green,
              onTap: _resetToCleanDemo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanupCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(context),
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        trailing: Icon(
          AppIcons.arrowForward,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        onTap: _isCleaning ? null : onTap,
      ),
    );
  }

  Future<void> _clearLocalData() async {
    await _performCleanup(
      'Clearing local data...',
      () async {
        final repo = LocalRepository.instance;
        await repo.clearAllData();
        await repo.initializeStreams();
      },
    );
  }

  Future<void> _clearDatabase() async {
    await _performCleanup(
      'Clearing database...',
      () async {
        // Use CompleteDataManager to clear Supabase data
        await CompleteDataManager.performCompleteCleanup();
      },
    );
  }

  Future<void> _completeCleanup() async {
    await _performCleanup(
      'Performing complete cleanup...',
      () => CompleteDataManager.performCompleteCleanup(),
    );
  }

  Future<void> _resetToCleanDemo() async {
    await _performCleanup(
      'Resetting to clean demo data...',
      () async {
        await CompleteDataManager.performCompleteCleanup();
        // Add minimal demo data after cleanup
        final repo = LocalRepository.instance;
        await repo.seedMinimalDemoData();
      },
    );
  }

  Future<void> _performCleanup(String operation, Future<void> Function() cleanupFunction) async {
    if (_isCleaning) return;

    setState(() {
      _isCleaning = true;
      _currentOperation = operation;
      _progress = 0.0;
    });

    try {
      // Simulate progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _progress = i / 100.0;
        });
      }

      // Perform actual cleanup
      await cleanupFunction();

      setState(() {
        _currentOperation = 'Cleanup completed successfully!';
        _progress = 1.0;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data cleanup completed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset after delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isCleaning = false;
        _currentOperation = '';
        _progress = 0.0;
      });

    } catch (e) {
      setState(() {
        _isCleaning = false;
        _currentOperation = '';
        _progress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during cleanup: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
