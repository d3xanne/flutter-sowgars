import 'package:flutter/material.dart';
import 'package:sample/services/data_export_service.dart';

class DataExportWidget extends StatefulWidget {
  const DataExportWidget({Key? key}) : super(key: key);

  @override
  State<DataExportWidget> createState() => _DataExportWidgetState();
}

class _DataExportWidgetState extends State<DataExportWidget> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Export & Reports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    'Export All Data',
                    Icons.download,
                    const Color(0xFF4CAF50),
                    _exportAllData,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExportButton(
                    'Generate Report',
                    Icons.assessment,
                    const Color(0xFF2196F3),
                    _generateReport,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    'Sugar Records',
                    Icons.eco,
                    const Color(0xFF4CAF50),
                    () => _exportSpecificData('sugar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExportButton(
                    'Inventory',
                    Icons.inventory,
                    const Color(0xFF2196F3),
                    () => _exportSpecificData('inventory'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    'Suppliers',
                    Icons.business,
                    const Color(0xFFFF9800),
                    () => _exportSpecificData('suppliers'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExportButton(
                    'Alerts',
                    Icons.notifications,
                    const Color(0xFFF44336),
                    () => _exportSpecificData('alerts'),
                  ),
                ),
              ],
            ),
            if (_isExporting) ...[
              const SizedBox(height: 12),
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: _isExporting ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);
    
    try {
      await DataExportService.exportAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data exported successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isExporting = true);
    
    try {
      await DataExportService.generateComprehensiveReport();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: Color(0xFF2196F3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportSpecificData(String dataType) async {
    setState(() => _isExporting = true);
    
    try {
      switch (dataType) {
        case 'sugar':
          await DataExportService.exportSugarRecords();
          break;
        case 'inventory':
          await DataExportService.exportInventoryData();
          break;
        case 'suppliers':
          await DataExportService.exportSupplierData();
          break;
        case 'alerts':
          await DataExportService.exportAlertData();
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${dataType.toUpperCase()} data exported successfully!'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }
}
