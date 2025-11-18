import 'package:flutter/material.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';

class DataFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> currentFilters;

  const DataFilterWidget({
    Key? key,
    required this.onFiltersChanged,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<DataFilterWidget> createState() => _DataFilterWidgetState();
}

class _DataFilterWidgetState extends State<DataFilterWidget> {
  late Map<String, dynamic> _filters;
  String _selectedDateRange = 'all';
  String _selectedCategory = 'all';
  String _selectedSeverity = 'all';

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDateRangeFilter(),
            const SizedBox(height: 12),
            _buildCategoryFilter(),
            const SizedBox(height: 12),
            _buildSeverityFilter(),
            const SizedBox(height: 12),
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('All Time', 'all', _selectedDateRange, (value) {
              setState(() => _selectedDateRange = value);
              _updateFilters();
            }),
            _buildFilterChip('Last 7 Days', '7days', _selectedDateRange, (value) {
              setState(() => _selectedDateRange = value);
              _updateFilters();
            }),
            _buildFilterChip('Last 30 Days', '30days', _selectedDateRange, (value) {
              setState(() => _selectedDateRange = value);
              _updateFilters();
            }),
            _buildFilterChip('Last 3 Months', '3months', _selectedDateRange, (value) {
              setState(() => _selectedDateRange = value);
              _updateFilters();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('All', 'all', _selectedCategory, (value) {
              setState(() => _selectedCategory = value);
              _updateFilters();
            }),
            _buildFilterChip('Sugar Records', 'sugar', _selectedCategory, (value) {
              setState(() => _selectedCategory = value);
              _updateFilters();
            }),
            _buildFilterChip('Inventory', 'inventory', _selectedCategory, (value) {
              setState(() => _selectedCategory = value);
              _updateFilters();
            }),
            _buildFilterChip('Suppliers', 'suppliers', _selectedCategory, (value) {
              setState(() => _selectedCategory = value);
              _updateFilters();
            }),
            _buildFilterChip('Alerts', 'alerts', _selectedCategory, (value) {
              setState(() => _selectedCategory = value);
              _updateFilters();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSeverityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alert Severity',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('All', 'all', _selectedSeverity, (value) {
              setState(() => _selectedSeverity = value);
              _updateFilters();
            }),
            _buildFilterChip('High', 'high', _selectedSeverity, (value) {
              setState(() => _selectedSeverity = value);
              _updateFilters();
            }),
            _buildFilterChip('Medium', 'medium', _selectedSeverity, (value) {
              setState(() => _selectedSeverity = value);
              _updateFilters();
            }),
            _buildFilterChip('Low', 'low', _selectedSeverity, (value) {
              setState(() => _selectedSeverity = value);
              _updateFilters();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickFilterButton(
                'Low Stock Items',
                Icons.warning,
                const Color(0xFFFF5722),
                () => _applyQuickFilter('lowStock'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickFilterButton(
                'Unread Alerts',
                Icons.notifications_active,
                const Color(0xFFF44336),
                () => _applyQuickFilter('unreadAlerts'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickFilterButton(
                'Recent Growth',
                Icons.trending_up,
                const Color(0xFF4CAF50),
                () => _applyQuickFilter('recentGrowth'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickFilterButton(
                'High Spending',
                Icons.attach_money,
                const Color(0xFFFF9800),
                () => _applyQuickFilter('highSpending'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue, Function(String) onSelected) {
    final isSelected = selectedValue == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildQuickFilterButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFilters() {
    _filters = {
      'dateRange': _selectedDateRange,
      'category': _selectedCategory,
      'severity': _selectedSeverity,
    };
    widget.onFiltersChanged(_filters);
  }

  void _applyQuickFilter(String filterType) {
    switch (filterType) {
      case 'lowStock':
        _filters['quickFilter'] = 'lowStock';
        break;
      case 'unreadAlerts':
        _filters['quickFilter'] = 'unreadAlerts';
        break;
      case 'recentGrowth':
        _filters['quickFilter'] = 'recentGrowth';
        break;
      case 'highSpending':
        _filters['quickFilter'] = 'highSpending';
        break;
    }
    widget.onFiltersChanged(_filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedDateRange = 'all';
      _selectedCategory = 'all';
      _selectedSeverity = 'all';
      _filters = {};
    });
    widget.onFiltersChanged(_filters);
  }
}

// Data filtering utilities
class DataFilterUtils {
  static List<T> applyFilters<T>(List<T> data, Map<String, dynamic> filters) {
    if (filters.isEmpty) return data;

    List<T> filteredData = List<T>.from(data);

    // Apply date range filter
    if (filters['dateRange'] != null && filters['dateRange'] != 'all') {
      filteredData = _filterByDateRange(filteredData, filters['dateRange']);
    }

    // Apply quick filters
    if (filters['quickFilter'] != null) {
      filteredData = _applyQuickFilter(filteredData, filters['quickFilter']);
    }

    return filteredData;
  }

  static List<T> _filterByDateRange<T>(List<T> data, String dateRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (dateRange) {
      case '7days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '30days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '3months':
        startDate = now.subtract(const Duration(days: 90));
        break;
      default:
        return data;
    }

    return data.where((item) {
      DateTime itemDate;
      if (item is SugarRecord) {
        itemDate = DateTime.parse(item.date);
      } else if (item is InventoryItem) {
        itemDate = DateTime.parse(item.lastUpdated);
      } else if (item is SupplierTransaction) {
        itemDate = DateTime.parse(item.date);
      } else if (item is AlertItem) {
        itemDate = item.timestamp;
      } else {
        return true;
      }
      return itemDate.isAfter(startDate);
    }).toList();
  }

  static List<T> _applyQuickFilter<T>(List<T> data, String quickFilter) {
    switch (quickFilter) {
      case 'lowStock':
        return data.where((item) {
          if (item is InventoryItem) {
            return item.quantity <= 10;
          }
          return false;
        }).toList();
      case 'unreadAlerts':
        return data.where((item) {
          if (item is AlertItem) {
            return !item.read;
          }
          return false;
        }).toList();
      case 'recentGrowth':
        return data.where((item) {
          if (item is SugarRecord) {
            final itemDate = DateTime.parse(item.date);
            return DateTime.now().difference(itemDate).inDays <= 7;
          }
          return false;
        }).toList();
      case 'highSpending':
        return data.where((item) {
          if (item is SupplierTransaction) {
            return item.amount > 10000;
          }
          return false;
        }).toList();
      default:
        return data;
    }
  }
}
