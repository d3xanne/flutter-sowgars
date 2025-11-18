// MODIFY THIS FILE: lib/sugar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/inventory.dart';
import 'package:sample/weather.dart';
import 'package:sample/theme/mobile_theme.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/activity_tracker_service.dart';
import 'package:sample/widgets/modern_search_bar.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/widgets/standardized_ui.dart';
import 'package:sample/widgets/responsive_dialog.dart';

class Sugar extends StatefulWidget {
  const Sugar({Key? key}) : super(key: key);

  @override
  State<Sugar> createState() => _SugarState();
}

class _SugarState extends State<Sugar> with SingleTickerProviderStateMixin {
  // Tab control
  int _currentTab = 0;
  
  // Controllers for form fields
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Dropdown values
  String _selectedVariety = 'Phil 8013';
  String _selectedSoilTest = 'pH 6.5, Good fertility';
  String _selectedFertilizer = 'NPK 14-14-14';

  // Predefined lists for dropdowns
  final List<String> _varieties = [
    'Phil 8013',
    'VMC 86-550',
    'Phil 2000',
    'Phil 2004',
    'Phil 2009',
    'Phil 2010',
    'Phil 2013',
    'Phil 2014',
    'Phil 7544',
    'Phil 8337',
    'Phil 8943',
    'Phil 9101',
    'VMC 84-524',
    'VMC 87-599',
    'VMC 89-985',
    'VMC 90-963',
    'VMC 91-567',
    'VMC 95-272',
  ];

  final List<String> _soilTests = [
    'pH 6.5, Good fertility',
    'pH 6.2, Medium fertility',
    'pH 5.8, Low fertility',
    'pH 7.0, High fertility',
    'pH 6.8, Good fertility',
    'pH 6.0, Medium fertility',
    'pH 5.5, Poor fertility',
    'pH 7.2, Alkaline soil',
  ];

  final List<String> _fertilizers = [
    'NPK 14-14-14',
    'Urea + Potash',
    'Ammonium Sulfate',
    'Complete 16-16-16',
    'Organic Compost',
    'Vermicompost',
    'Urea (46-0-0)',
    'Muriate of Potash',
    'DAP (18-46-0)',
    'Ammonium Phosphate',
  ];

  // Animation controller for list items
  late AnimationController _animationController;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  final LocalRepository _repo = LocalRepository.instance;
  List<SugarRecord> _records = [];
  List<SugarRecord> _filteredRecords = [];
  bool _isEditing = false;
  int _editingIndex = -1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Set current date
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _load();
    _repo.sugarRecordsStream.listen((list) {
      if (mounted) {
        setState(() {
          _records = list;
          _filterRecords();
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    _heightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await _repo.getSugarRecords();
    if (list.isEmpty) {
      final seed = [
        SugarRecord(
          id: 's1',
          date: '2025-05-15',
          variety: 'Phil 8013',
          soilTest: 'pH 6.5, Good fertility',
          fertilizer: 'NPK 14-14-14',
          heightCm: 180,
          notes: 'Healthy growth, no pests observed',
        ),
        SugarRecord(
          id: 's2',
          date: '2025-05-10',
          variety: 'VMC 86-550',
          soilTest: 'pH 6.2, Medium fertility',
          fertilizer: 'Urea + Potash',
          heightCm: 165,
          notes: 'Some leaf yellowing in section 3',
        ),
      ];
      await _repo.saveSugarRecords(seed);
      final loaded = await _repo.getSugarRecords();
      if (mounted) {
        setState(() {
          _records = loaded;
          _filterRecords();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _records = list;
          _filterRecords();
        });
      }
    }
  }

  void _filterRecords() {
    if (_searchQuery.isEmpty) {
      _filteredRecords = List.from(_records);
    } else {
      _filteredRecords = _records.where((record) {
        return record.variety.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               record.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        _filterRecords();
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final height = int.tryParse(_heightController.text) ?? 0;
      
      try {
        if (_isEditing) {
          final id = _records[_editingIndex].id;
          await _updateSugarRecord(
            SugarRecord(
              id: id,
              date: _dateController.text,
              variety: _selectedVariety,
              soilTest: _selectedSoilTest,
              fertilizer: _selectedFertilizer,
              heightCm: height,
              notes: _notesController.text,
            ),
          );
          if (mounted) {
            setState(() {
              _isEditing = false;
              _editingIndex = -1;
            });
          }
        } else {
          await _addSugarRecord(
            SugarRecord(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              date: _dateController.text,
              variety: _selectedVariety,
              soilTest: _selectedSoilTest,
              fertilizer: _selectedFertilizer,
              heightCm: height,
              notes: _notesController.text,
            ),
          );
        }

        // Clear form
        _clearForm();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Record updated successfully!'
                : 'Record saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _currentTab = 1;
                });
              },
            ),
          ),
        );

        // Simple growth alert
        if (height < 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Alert: Growth below 100 cm, inspect field.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          await AlertService.alertSugarRecordActivity(
            action: 'Low Growth Alert',
            variety: _selectedVariety,
            details: 'Recorded height ${height} cm is below threshold. Please inspect field.',
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving record: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Future<void> _addSugarRecord(SugarRecord rec) async {
    final list = await _repo.getSugarRecords();
    list.add(rec);
    await _repo.saveSugarRecords(list);
    
    // Update local records list immediately
    if (mounted) {
      setState(() {
        _records.add(rec);
      });
    }
    
    // Track activity
    ActivityTrackerService().trackSugarRecordAdded(rec.variety, rec.heightCm);
    
    // Add activity alert
    await AlertService.alertSugarRecordActivity(
      action: 'Added',
      variety: rec.variety,
      details: 'New sugar record added for ${rec.variety} variety. Height: ${rec.heightCm}cm, Date: ${rec.date}',
    );
  }

  Future<void> _updateSugarRecord(SugarRecord rec) async {
    final list = await _repo.getSugarRecords();
    final idx = list.indexWhere((e) => e.id == rec.id);
    if (idx != -1) {
      list[idx] = rec;
      await _repo.saveSugarRecords(list);
      
      // Update local records list immediately
      if (mounted) {
        setState(() {
          final localIdx = _records.indexWhere((e) => e.id == rec.id);
          if (localIdx != -1) {
            _records[localIdx] = rec;
          }
        });
      }
      
      // Track activity
      ActivityTrackerService().trackSugarRecordUpdated(rec.variety, rec.heightCm);
      
      // Add activity alert
      await AlertService.alertSugarRecordActivity(
        action: 'Updated',
        variety: rec.variety,
        details: 'Sugar record updated for ${rec.variety} variety. Height: ${rec.heightCm}cm, Date: ${rec.date}',
      );
    }
  }

  void _editRecord(int index) {
    final record = _records[index];
    if (mounted) {
      setState(() {
        _selectedVariety = record.variety;
        _selectedSoilTest = record.soilTest;
        _selectedFertilizer = record.fertilizer;
        _heightController.text = record.heightCm.toString();
        _notesController.text = record.notes;
        _dateController.text = record.date;
        _isEditing = true;
        _editingIndex = index;

        // Switch to edit tab
        setState(() {
          _currentTab = 0;
        });
      });
    }
  }

  void _deleteRecord(int index) {
    showStandardConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete this record? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteSugarRecord(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Record deleted successfully!'),
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

  Future<void> _deleteSugarRecord(int index) async {
    final record = _records[index];
    final id = record.id;
    
    // Use dedicated delete method for permanent deletion
    await _repo.deleteSugarRecord(id);
    
    // Update local records list immediately
    if (mounted) {
      setState(() {
        _records.removeWhere((e) => e.id == id);
      });
    }
    
    // Add activity alert
    await AlertService.alertSugarRecordActivity(
      action: 'Deleted',
      variety: record.variety,
      details: 'Sugar record deleted for ${record.variety} variety. Height: ${record.heightCm}cm, Date: ${record.date}',
    );
  }

  void _clearForm() {
    _heightController.clear();
    _notesController.clear();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (mounted) {
      setState(() {
        _selectedVariety = _varieties[0];
        _selectedSoilTest = _soilTests[0];
        _selectedFertilizer = _fertilizers[0];
        _isEditing = false;
        _editingIndex = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildNavigationDrawer(context),
        // MODIFY THIS FILE: lib/sugar.dart
// Find the AppBar section and replace it with this:

        // MODIFY THIS FILE: lib/sugar.dart
// Find the AppBar section and replace it with this:

        appBar: null,
        body: Column(
          children: [
                   // Custom Header
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: [Colors.green[700]!, Colors.green[600]!],
                       ),
                       borderRadius: const BorderRadius.only(
                         bottomLeft: Radius.circular(20),
                         bottomRight: Radius.circular(20),
                       ),
                     ),
                     child: Column(
                       children: [
                         Row(
                           children: [
                             const SizedBox(width: 16),
                             const Expanded(
                               child: Text(
                                 'Sugarcane Monitoring',
                                 style: TextStyle(
                                   fontSize: 24,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.white,
                                 ),
                               ),
                             ),
                           ],
                         ),
                  const SizedBox(height: 16),
                  // Custom Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _currentTab == 0 
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add/Edit Record',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: _currentTab == 0 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _currentTab == 1 
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View Records',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: _currentTab == 1 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
            // Add/Edit Record Tab
            SingleChildScrollView(
              child: Padding(
                padding: MobileTheme.getResponsivePadding(context),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isEditing
                                  ? Icons.edit_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isEditing
                                  ? 'Edit Sugarcane Record'
                                  : 'Add New Sugarcane Record',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Date field
                      _buildFormField(
                        label: 'Date',
                        controller: _dateController,
                        icon: Icons.calendar_today_rounded,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.green[700]!,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            _dateController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                        readOnly: true,
                      ),

                      // Variety dropdown
                      _buildDropdownField(
                        label: 'Variety of Sugarcane',
                        value: _selectedVariety,
                        items: _varieties,
                        icon: Icons.grass_rounded,
                        onChanged: (value) {
                          if (value != null && mounted) {
                            setState(() {
                              _selectedVariety = value;
                            });
                          }
                        },
                      ),

                      // Soil Test dropdown
                      _buildDropdownField(
                        label: 'Soil Test Results',
                        value: _selectedSoilTest,
                        items: _soilTests,
                        icon: Icons.landscape_rounded,
                        onChanged: (value) {
                          if (value != null && mounted) {
                            setState(() {
                              _selectedSoilTest = value;
                            });
                          }
                        },
                      ),

                      // Fertilizer dropdown
                      _buildDropdownField(
                        label: 'Fertilizer Used',
                        value: _selectedFertilizer,
                        items: _fertilizers,
                        icon: Icons.science_rounded,
                        onChanged: (value) {
                          if (value != null && mounted) {
                            setState(() {
                              _selectedFertilizer = value;
                            });
                          }
                        },
                      ),

                      // Height field
                      _buildFormField(
                        label: 'Heights of Sugarcane (cm)',
                        controller: _heightController,
                        icon: Icons.height_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter height';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      // Notes field
                      _buildFormField(
                        label: 'Additional Notes',
                        controller: _notesController,
                        icon: Icons.note_rounded,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20.0),

                      // Buttons
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 400;
                          return isSmallScreen
                              ? Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _saveRecord,
                                        icon: Icon(_isEditing
                                            ? Icons.update_rounded
                                            : Icons.save_rounded),
                                        label: Text(_isEditing ? 'Update' : 'Save'),
                                        style: StandardizedUI.elevatedButtonStyle(
                                          backgroundColor: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _clearForm,
                                        icon: const Icon(Icons.clear_rounded),
                                        label: const Text('Clear'),
                                        style: StandardizedUI.outlinedButtonStyle(
                                          foregroundColor: Colors.grey[700],
                                          borderColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _saveRecord,
                                        icon: Icon(_isEditing
                                            ? Icons.update_rounded
                                            : Icons.save_rounded),
                                        label: Text(_isEditing ? 'Update' : 'Save'),
                                        style: StandardizedUI.elevatedButtonStyle(
                                          backgroundColor: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _clearForm,
                                        icon: const Icon(Icons.clear_rounded),
                                        label: const Text('Clear'),
                                        style: StandardizedUI.outlinedButtonStyle(
                                          foregroundColor: Colors.grey[700],
                                          borderColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // View Records Tab
            _records.isEmpty
                ? StandardizedUI.emptyState(
                    message: 'No records found',
                    subtitle: 'Add a new record to get started',
                    icon: Icons.note_alt_outlined,
                    onAction: () {
                      setState(() => _currentTab = 0);
                    },
                    actionLabel: 'Add Record',
                  )
                : Column(
                    children: [
                      ModernSearchBar(
                        hintText: 'Search sugar records...',
                        onSearch: _onSearchChanged,
                        showFilter: true,
                        onFilterTap: () {
                          // Add filter functionality here
                        },
                      ),
                      Expanded(
                        child: AnimatedList(
                          initialItemCount: _filteredRecords.length,
                          itemBuilder: (context, index, animation) {
                            final record = _filteredRecords[index];
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Icon(Icons.grass_rounded,
                                  color: Colors.green[700]),
                            ),
                            title: Text(
                              record.variety,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'Date: ${record.date} | Height: ${record.heightCm} cm'),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            childrenPadding: const EdgeInsets.all(16),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRecordDetail(
                                      'Soil Test', record.soilTest),
                                  _buildRecordDetail(
                                      'Fertilizer', record.fertilizer),
                                  if (record.notes.isNotEmpty)
                                    _buildRecordDetail(
                                        'Notes', record.notes),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded,
                                            color: Colors.blue),
                                        onPressed: () => _editRecord(index),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_rounded,
                                            color: Colors.red),
                                        onPressed: () => _deleteRecord(index),
                                        tooltip: 'Delete',
                                      ),
                                    ],
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
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() => _currentTab = 0);
          },
          backgroundColor: Colors.green[700],
          child: const Icon(Icons.add_rounded),
          tooltip: 'Add New Record',
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MobileTheme.isMobile(context) ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.green[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.green[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              filled: true,
              fillColor: Colors.green[50],
              hintText: 'Enter $label',
            ),
            validator: validator,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.green[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Build a custom navigation drawer for this screen
  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.green[700],
              padding: EdgeInsets.only(
                top: 24 + MediaQuery.of(context).padding.top,
                bottom: 24,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Text(
                        'HE',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hacienda Elizabeth',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Talisay City, Negros Occidental',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                runSpacing: 8,
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.home_rounded, color: Colors.green),
                    title: const Text('Home'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.cloud_outlined, color: Colors.blue),
                    title: const Text('Weather Forecast'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Weather()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.grass_rounded, color: Colors.green),
                    title: const Text('Sugarcane Monitoring'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_rounded,
                        color: Colors.amber),
                    title: const Text('Inventory'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Inventory()),
                      );
                    },
                  ),
                  const Divider(color: Colors.green),
                  ListTile(
                    leading:
                        const Icon(Icons.settings_rounded, color: Colors.grey),
                    title: const Text('Settings'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded,
                        color: Colors.grey),
                    title: const Text('Help & Support'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(context);
                      // Add help functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(); // This is just a placeholder
  }
}
