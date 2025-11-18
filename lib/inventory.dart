import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/activity_tracker_service.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/theme/mobile_theme.dart';
import 'package:sample/widgets/standardized_ui.dart';
import 'package:sample/widgets/responsive_dialog.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _animationController;
  final LocalRepository _repo = LocalRepository.instance;
  final int _lowStockThreshold = 10;
  StreamSubscription<List<InventoryItem>>? _inventoryStreamSubscription;

  // Inventory items from repository
  List<InventoryItem> _inventoryItems = [];

  // Filter options
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Fertilizer',
    'Pesticide',
    'Herbicide',
    'Seeds',
    'Equipment'
  ];

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _onlyLowStock = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  String _selectedCategoryForm = 'Fertilizer';
  bool _isEditing = false;
  int _editingIndex = -1;

  List<InventoryItem> get _filteredItems {
    return _inventoryItems.where((item) {
      // Apply category filter
      final categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      // Apply search filter
      final nameMatch = item.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      // Low stock filter
      final lowMatch =
          !_onlyLowStock || item.quantity <= _lowStockThreshold;

      return categoryMatch && nameMatch && lowMatch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _load();
    _inventoryStreamSubscription = _repo.inventoryItemsStream.listen((list) {
      if (mounted) {
        setState(() {
          _inventoryItems = list;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _inventoryStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await _repo.getInventoryItems();
      if (list.isEmpty) {
        // Add sample data if empty
        final seed = [
          InventoryItem(
            id: 'inv1',
            name: 'NPK Fertilizer',
            category: 'Fertilizer',
            quantity: 25,
            unit: 'bags',
            lastUpdated: '2025-05-15',
          ),
          InventoryItem(
            id: 'inv2',
            name: 'Urea',
            category: 'Fertilizer',
            quantity: 15,
            unit: 'bags',
            lastUpdated: '2025-05-12',
          ),
          InventoryItem(
            id: 'inv3',
            name: 'Pesticide A',
            category: 'Pesticide',
            quantity: 10,
            unit: 'liters',
            lastUpdated: '2025-05-10',
          ),
        ];
        await _repo.saveInventoryItems(seed);
        final loaded = await _repo.getInventoryItems();
        if (mounted) {
          setState(() {
            _inventoryItems = loaded;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _inventoryItems = list;
          });
        }
      }
    } catch (e) {
      print('Error loading inventory: $e');
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final item = InventoryItem(
        id: _isEditing ? _inventoryItems[_editingIndex].id : DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text,
        category: _selectedCategoryForm,
        quantity: quantity,
        unit: _unitController.text,
        lastUpdated: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      final wasEditing = _isEditing; // Store the editing state before clearing it
      
      if (_isEditing) {
        _updateInventoryItem(item);
        _isEditing = false;
        _editingIndex = -1;
      } else {
        _addInventoryItem(item);
      }

      _clearForm();
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasEditing ? 'Item updated successfully!' : 'Item added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addInventoryItem(InventoryItem item) async {
    final list = await _repo.getInventoryItems();
    list.add(item);
    await _repo.saveInventoryItems(list);
    
    // Update local inventory list immediately
    if (mounted) {
      setState(() {
        _inventoryItems.add(item);
        _filteredItems.add(item);
      });
    }
    
    // Track activity
    ActivityTrackerService().trackInventoryItemAdded(item.name, item.quantity);
    
    // Add activity alert
    await AlertService.alertInventoryActivity(
      action: 'Added',
      itemName: item.name,
      details: 'New inventory item added: ${item.name} (${item.quantity} ${item.unit})',
    );
  }

  Future<void> _updateInventoryItem(InventoryItem item) async {
    final list = await _repo.getInventoryItems();
    final idx = list.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      list[idx] = item;
      await _repo.saveInventoryItems(list);
      
      // Update local inventory list immediately
      if (mounted) {
        setState(() {
          final localIdx = _inventoryItems.indexWhere((e) => e.id == item.id);
          if (localIdx != -1) {
            _inventoryItems[localIdx] = item;
          }
          // Update filtered items as well
          final filteredIdx = _filteredItems.indexWhere((e) => e.id == item.id);
          if (filteredIdx != -1) {
            _filteredItems[filteredIdx] = item;
          }
        });
      }
      
      // Track activity
      ActivityTrackerService().trackInventoryItemUpdated(item.name, item.quantity);
      
      // Add activity alert
      await AlertService.alertInventoryActivity(
        action: 'Updated',
        itemName: item.name,
        details: 'Inventory item updated: ${item.name} (${item.quantity} ${item.unit})',
      );
    }
  }

  Future<void> _deleteInventoryItem(int index) async {
    final item = _filteredItems[index];
    final id = item.id;
    
    // Use dedicated delete method for permanent deletion
    await _repo.deleteInventoryItem(id);
    
    // Update local inventory list immediately
    if (mounted) {
      setState(() {
        _inventoryItems.removeWhere((e) => e.id == id);
        _filteredItems.removeWhere((e) => e.id == id);
      });
    }
    
    // Add activity alert
    await AlertService.alertInventoryActivity(
      action: 'Deleted',
      itemName: item.name,
      details: 'Inventory item deleted: ${item.name} (${item.quantity} ${item.unit})',
    );
  }

  void _editItem(int index) {
    final item = _filteredItems[index];
    setState(() {
      _nameController.text = item.name;
      _selectedCategoryForm = item.category;
      _quantityController.text = item.quantity.toString();
      _unitController.text = item.unit;
      _isEditing = true;
      _editingIndex = _inventoryItems.indexWhere((e) => e.id == item.id);
    });
    // Open the dialog after setting up the form
    _showAddItemDialog();
  }

  void _clearForm() {
    _nameController.clear();
    _quantityController.clear();
    _unitController.clear();
    _selectedCategoryForm = 'Fertilizer';
    _isEditing = false;
    _editingIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: scheme.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: MobileTheme.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search inventory...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: MobileTheme.isMobile(context) ? 12 : 16),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: MobileTheme.isMobile(context) ? 12 : 16),
                    Expanded(
                      child: FilterChip(
                        label: Text('Low Stock (≤$_lowStockThreshold)'),
                        selected: _onlyLowStock,
                        onSelected: (selected) {
                          setState(() {
                            _onlyLowStock = selected;
                          });
                        },
                        selectedColor: scheme.errorContainer.withValues(alpha: 0.3),
                        checkmarkColor: scheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Inventory List
          Expanded(
            child: _filteredItems.isEmpty
                ? StandardizedUI.emptyState(
                    message: 'No inventory items found',
                    subtitle: 'Add some items to get started',
                    icon: Icons.inventory_2_rounded,
                    onAction: () {
                      _clearForm();
                      _showAddItemDialog();
                    },
                    actionLabel: 'Add Item',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isLowStock = item.quantity <= _lowStockThreshold;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(item.category),
                            child: Icon(
                              _getCategoryIcon(item.category),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity} ${item.unit}'),
                              Text(
                                'Last updated: ${item.lastUpdated}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLowStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'LOW STOCK',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editItem(index);
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(index);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_rounded, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_rounded, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearForm();
          _showAddItemDialog();
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddItemDialog() {
    showResponsiveDialog(
      context: context,
      title: _isEditing ? 'Edit Item' : 'Add New Item',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryForm,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.where((c) => c != 'All').map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryForm = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Enter valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter unit';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _clearForm();
          },
          child: const Text('Cancel'),
          style: StandardizedUI.textButtonStyle(),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: Text(_isEditing ? 'Update' : 'Add'),
          style: StandardizedUI.elevatedButtonStyle(),
        ),
      ],
    );
  }

  void _showDeleteDialog(int index) {
    showStandardConfirmation(
      context: context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete "${_filteredItems[index].name}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteInventoryItem(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item deleted successfully!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StandardizedUI.radiusM),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fertilizer':
        return Colors.green;
      case 'Pesticide':
        return Colors.red;
      case 'Herbicide':
        return Colors.orange;
      case 'Seeds':
        return Colors.brown;
      case 'Equipment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fertilizer':
        return Icons.eco_rounded;
      case 'Pesticide':
        return Icons.bug_report_rounded;
      case 'Herbicide':
        return Icons.grass_rounded;
      case 'Seeds':
        return Icons.spa_rounded;
      case 'Equipment':
        return Icons.build_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}
