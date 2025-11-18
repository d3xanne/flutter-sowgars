import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/activity_tracker_service.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/constants/app_icons.dart';
import 'package:sample/widgets/responsive_builder.dart';
import 'package:sample/widgets/responsive_dialog.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({Key? key}) : super(key: key);

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final LocalRepository _repo = LocalRepository.instance;
  List<SupplierTransaction> _transactions = [];
  List<SupplierTransaction> _archivedTransactions = [];
  StreamSubscription? _subscription;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _load();
    _subscription = _repo.supplierTransactionsStream.listen((event) async {
      if (mounted) {
        final activeTx = await _repo.getActiveSupplierTransactions();
        final archivedTx = await _repo.getArchivedSupplierTransactions();
        setState(() {
          _transactions = activeTx;
          _archivedTransactions = archivedTx;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final tx = await _repo.getActiveSupplierTransactions();
    final archivedTx = await _repo.getArchivedSupplierTransactions();
    
    if (tx.isEmpty && archivedTx.isEmpty) {
      final seed = [
        SupplierTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          supplierName: 'ABC Agro Supply',
          itemName: 'NPK 14-14-14',
          quantity: 20,
          unit: 'bags',
          amount: 18000.0,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          notes: 'Bulk discount applied',
        ),
      ];
      await _repo.saveSupplierTransactions(seed);
      if (mounted) {
        setState(() {
          _transactions = seed;
          _archivedTransactions = archivedTx;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _transactions = tx;
          _archivedTransactions = archivedTx;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpend = _transactions.fold<double>(0, (p, e) => p + e.amount);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? 'Archived Transactions' : 'Supplier Transactions'),
        backgroundColor: scheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? AppIcons.folder : AppIcons.archive),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
            tooltip: _showArchived ? 'View Active' : 'View Archived',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveUtils.isMobile(context);
          final isTablet = ResponsiveUtils.isTablet(context);
          
          return Column(
            children: [
              Padding(
                padding: ResponsiveUtils.getPadding(context),
                child: isMobile
                    ? Column(
                        children: [
                          _stat(
                            _showArchived ? 'Archived' : 'Active',
                            _showArchived ? _archivedTransactions.length.toString() : _transactions.length.toString(),
                            _showArchived ? AppIcons.archive : AppIcons.receipt,
                            scheme.primary,
                            context,
                          ),
                          const SizedBox(height: 12),
                          _stat(
                            'Total Spend',
                            '₱${(_showArchived ? _archivedTransactions.fold<double>(0, (p, e) => p + e.amount) : totalSpend).toStringAsFixed(2)}',
                            AppIcons.payments,
                            scheme.secondary,
                            context,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _stat(
                              _showArchived ? 'Archived' : 'Active',
                              _showArchived ? _archivedTransactions.length.toString() : _transactions.length.toString(),
                              _showArchived ? AppIcons.archive : AppIcons.receipt,
                              scheme.primary,
                              context,
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 16),
                          Expanded(
                            child: _stat(
                              'Total Spend',
                              '₱${(_showArchived ? _archivedTransactions.fold<double>(0, (p, e) => p + e.amount) : totalSpend).toStringAsFixed(2)}',
                              AppIcons.payments,
                              scheme.secondary,
                              context,
                            ),
                          ),
                        ],
                      ),
              ),
              Expanded(
                child: _showArchived
                    ? (_archivedTransactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: ResponsiveUtils.getPadding(context),
                              child: Text(
                                'No archived transactions',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: ResponsiveUtils.getHorizontalPadding(context),
                            itemCount: _archivedTransactions.length,
                            itemBuilder: (context, index) {
                              final t = _archivedTransactions[index];
                              return _buildArchivedTransactionCard(t, index, context);
                            }))
                    : (_transactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: ResponsiveUtils.getPadding(context),
                              child: Text(
                                'No transactions yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: ResponsiveUtils.getHorizontalPadding(context),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final t = _transactions[index];
                              return _buildTransactionCard(t, index, context, isMobile);
                            })),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(AppIcons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color, BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Container(
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getIconSize(context, 24),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(SupplierTransaction t, int index, BuildContext context, bool isMobile) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getSpacing(context, 8),
        vertical: ResponsiveUtils.getSpacing(context, 6),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal[100],
          radius: ResponsiveUtils.getIconSize(context, 20) / 2,
          child: Icon(
            Icons.store_rounded,
            color: Colors.teal,
            size: ResponsiveUtils.getIconSize(context, 20),
          ),
        ),
        title: Text(
          t.supplierName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getFontSize(context, 16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
            Text(
              '${t.itemName} • ${t.quantity} ${t.unit}',
              style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14)),
            ),
            Text(
              'Date: ${t.date}',
              style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 12)),
            ),
            if (t.notes.isNotEmpty)
              Text(
                t.notes,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 12),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: isMobile ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: isMobile
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddOrEditDialog(existing: t, index: index);
                  } else if (value == 'archive') {
                    _showArchiveDialog(index);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(AppIcons.edit, color: Colors.blue, size: ResponsiveUtils.getIconSize(context, 20)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Text('Edit', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(AppIcons.archive, color: Colors.orange, size: ResponsiveUtils.getIconSize(context, 20)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Text('Archive', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₱${t.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddOrEditDialog(existing: t, index: index);
                      } else if (value == 'archive') {
                        _showArchiveDialog(index);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(AppIcons.edit, color: Colors.blue, size: ResponsiveUtils.getIconSize(context, 20)),
                            SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                            Text('Edit', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(AppIcons.archive, color: Colors.orange, size: ResponsiveUtils.getIconSize(context, 20)),
                            SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                            Text('Archive', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        onTap: () => _showAddOrEditDialog(existing: t, index: index),
        isThreeLine: !isMobile && t.notes.isNotEmpty,
      ),
    );
  }

  Future<void> _showAddOrEditDialog({SupplierTransaction? existing, int? index}) async {
    final supplierCtrl = TextEditingController(text: existing?.supplierName ?? '');
    final itemCtrl = TextEditingController(text: existing?.itemName ?? '');
    final qtyCtrl = TextEditingController(text: existing?.quantity.toString() ?? '');
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    String unit = existing?.unit ?? 'bags';
    String date = existing?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    await showResponsiveDialog(
      context: context,
      title: existing == null ? 'Add Transaction' : 'Edit Transaction',
      content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: supplierCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: itemCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: unit,
                      items: ['bags', 'kg', 'liters', 'pieces']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => unit = v ?? unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₱)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: date),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(date) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    if (mounted) {
                      setState(() {
                        date = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
        ),
        ElevatedButton(
            onPressed: () async {
              final list = List<SupplierTransaction>.from(_transactions);
              final tx = SupplierTransaction(
                id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                supplierName: supplierCtrl.text.trim(),
                itemName: itemCtrl.text.trim(),
                quantity: int.tryParse(qtyCtrl.text) ?? 0,
                unit: unit,
                amount: double.tryParse(amountCtrl.text) ?? 0,
                date: date,
                notes: notesCtrl.text.trim(),
              );
              if (existing == null) {
                list.add(tx);
              } else {
                list[index!] = tx;
              }
              await _repo.saveSupplierTransactions(list);
              
              // Update local transactions list immediately
              if (mounted) {
                setState(() {
                  _transactions = list;
                });
              }
              
              // Track activity
              if (existing == null) {
                ActivityTrackerService().trackSupplierTransactionAdded(tx.supplierName, tx.amount);
              } else {
                ActivityTrackerService().trackActivity(
                  ActivityType.supplierTransactionUpdated,
                  'Supplier Transaction Updated',
                  'Updated transaction with ${tx.supplierName} for ₱${tx.amount.toStringAsFixed(2)}',
                  metadata: {'supplierName': tx.supplierName, 'amount': tx.amount},
                );
              }
              
              // Add activity alert
              if (existing == null) {
                await AlertService.alertSupplierActivity(
                  action: 'Added',
                  supplierName: tx.supplierName,
                  details: 'New transaction added: ${tx.itemName} (${tx.quantity} ${tx.unit}) - ₱${tx.amount.toStringAsFixed(2)}',
                );
              } else {
                await AlertService.alertSupplierActivity(
                  action: 'Updated',
                  supplierName: tx.supplierName,
                  details: 'Transaction updated: ${tx.itemName} (${tx.quantity} ${tx.unit}) - ₱${tx.amount.toStringAsFixed(2)}',
                );
              }
              
              if (mounted) Navigator.pop(context);
            },
          child: Text(
            existing == null ? 'Add' : 'Update',
            style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14)),
          ),
        ),
      ],
    );
  }

  void _showArchiveDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Transaction'),
        content: Text('Are you sure you want to archive this transaction with ${_transactions[index].supplierName}? You can restore it later if needed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _archiveTransaction(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction archived successfully! You can view it in the archived section.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Archive'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _archiveTransaction(int index) async {
    final transaction = _transactions[index];
    final id = transaction.id;
    
    // Use archive method instead of delete
    await _repo.archiveSupplierTransaction(id);
    
    // Update local transactions list immediately
    if (mounted) {
      setState(() {
        _transactions.removeWhere((e) => e.id == id);
      });
    }
  }
  
  Future<void> _restoreTransaction(int index) async {
    final transaction = _archivedTransactions[index];
    final id = transaction.id;
    
    // Use restore method
    await _repo.restoreSupplierTransaction(id);
    
    // Update local transactions list immediately
    if (mounted) {
      setState(() {
        _archivedTransactions.removeWhere((e) => e.id == id);
      });
    }
  }
  
  Widget _buildArchivedTransactionCard(SupplierTransaction transaction, int index, BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getSpacing(context, 8),
        vertical: ResponsiveUtils.getSpacing(context, 6),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: ResponsiveUtils.getIconSize(context, 20) / 2,
          child: Icon(
            Icons.archive,
            color: Colors.grey,
            size: ResponsiveUtils.getIconSize(context, 20),
          ),
        ),
        title: Text(
          transaction.supplierName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getFontSize(context, 16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.itemName} - ${transaction.quantity} ${transaction.unit}'),
            Text('₱${transaction.amount.toStringAsFixed(2)} • ${transaction.date}'),
            if (transaction.archivedAt != null)
              Text(
                'Archived: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(transaction.archivedAt!))}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: isMobile
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'restore') {
                    _restoreTransaction(index);
                  } else if (value == 'delete') {
                    _showPermanentDeleteDialog(index);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'restore',
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: Colors.green, size: ResponsiveUtils.getIconSize(context, 20)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Text('Restore', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: Colors.red, size: ResponsiveUtils.getIconSize(context, 20)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Text('Delete Forever', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.restore,
                      color: Colors.green,
                      size: ResponsiveUtils.getIconSize(context, 24),
                    ),
                    onPressed: () => _restoreTransaction(index),
                    tooltip: 'Restore',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: ResponsiveUtils.getIconSize(context, 24),
                    ),
                    onPressed: () => _showPermanentDeleteDialog(index),
                    tooltip: 'Permanent Delete',
                  ),
                ],
              ),
        isThreeLine: true,
      ),
    );
  }
  
  void _showPermanentDeleteDialog(int index) {
    final transaction = _archivedTransactions[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanent Delete'),
        content: Text('Are you sure you want to permanently delete this archived transaction with ${transaction.supplierName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _permanentDeleteTransaction(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction permanently deleted!'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  Future<void> _permanentDeleteTransaction(int index) async {
    final transaction = _archivedTransactions[index];
    final id = transaction.id;
    
    // Use permanent delete method
    await _repo.deleteSupplierTransaction(id);
    
    // Update local transactions list immediately
    if (mounted) {
      setState(() {
        _archivedTransactions.removeWhere((e) => e.id == id);
      });
    }
  }
}


