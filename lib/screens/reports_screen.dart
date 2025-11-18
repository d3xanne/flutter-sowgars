import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/services/data_export_service.dart';
import 'package:sample/widgets/responsive_builder.dart';
import 'package:sample/widgets/responsive_dialog.dart';
import 'package:sample/models/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSugarRecordsReport(),
                      _buildInventoryReport(),
                      _buildSupplierReport(),
                      _buildExportOptions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          padding: ResponsiveUtils.getPadding(context),
          child: Row(
            children: [
              SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 8)),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assessment,
                  color: Colors.white,
                  size: ResponsiveUtils.getIconSize(context, 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isSmallScreen) ...[
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                      Text(
                        'Data reports and export functionality',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  print('🔍 Reports Screen: Manual refresh triggered');
                  setState(() {
                    // Trigger rebuild of all FutureBuilders
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: ResponsiveUtils.getIconSize(context, 24),
                ),
                tooltip: 'Refresh Reports',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          margin: ResponsiveUtils.getHorizontalPadding(context),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getFontSize(context, isSmallScreen ? 10 : 12),
            ),
            isScrollable: isMobile, // Make tabs scrollable on mobile
            tabs: [
              Tab(
                text: isSmallScreen ? 'Sugar' : 'Sugar Records',
                icon: isSmallScreen ? const Icon(Icons.agriculture, size: 16) : null,
              ),
              Tab(
                text: 'Inventory',
                icon: isSmallScreen ? const Icon(Icons.inventory_2, size: 16) : null,
              ),
              Tab(
                text: 'Suppliers',
                icon: isSmallScreen ? const Icon(Icons.business, size: 16) : null,
              ),
              Tab(
                text: 'Export',
                icon: isSmallScreen ? const Icon(Icons.file_download, size: 16) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSugarRecordsReport() {
    return FutureBuilder<List<SugarRecord>>(
      future: LocalRepository.instance.getSugarRecords(),
      builder: (context, snapshot) {
        print('🔍 Sugar Records Report - Connection state: ${snapshot.connectionState}');
        print('🔍 Sugar Records Report - Has data: ${snapshot.hasData}');
        print('🔍 Sugar Records Report - Has error: ${snapshot.hasError}');
        
        if (snapshot.hasError) {
          print('🔍 Sugar Records Report - Error: ${snapshot.error}');
          return _buildErrorState('Error loading sugar records: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final records = snapshot.data ?? [];
        print('🔍 Sugar Records Report - Records count: ${records.length}');
        
        if (records.isEmpty) {
          return _buildEmptyState(
            Icons.agriculture,
            'No Sugar Records',
            'Start adding sugarcane monitoring records to see them here.',
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveUtils.getPadding(context),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportHeader('Sugar Records Report', records.length),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                _buildSugarStatistics(records),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                _buildDataTable(
                  ['Date', 'Variety', 'Soil Test', 'Fertilizer', 'Height (cm)', 'Notes'],
                  records.map((record) => [
                    record.date,
                    record.variety,
                    record.soilTest,
                    record.fertilizer,
                    record.heightCm.toString(),
                    record.notes.isNotEmpty ? record.notes : 'No notes',
                  ]).toList(),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryReport() {
    return FutureBuilder<List<InventoryItem>>(
      future: LocalRepository.instance.getInventoryItems(),
      builder: (context, snapshot) {
        print('🔍 Inventory Report - Connection state: ${snapshot.connectionState}');
        print('🔍 Inventory Report - Has data: ${snapshot.hasData}');
        print('🔍 Inventory Report - Has error: ${snapshot.hasError}');
        
        if (snapshot.hasError) {
          print('🔍 Inventory Report - Error: ${snapshot.error}');
          return _buildErrorState('Error loading inventory: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final items = snapshot.data ?? [];
        print('🔍 Inventory Report - Items count: ${items.length}');
        
        if (items.isEmpty) {
          return _buildEmptyState(
            Icons.inventory_2,
            'No Inventory Items',
            'Add inventory items to track your supplies.',
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveUtils.getPadding(context),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportHeader('Inventory Report', items.length),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                _buildInventoryStatistics(items),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                _buildDataTable(
                  ['Item', 'Category', 'Quantity', 'Unit', 'Last Updated'],
                  items.map((item) => [
                    item.name,
                    item.category,
                    item.quantity.toString(),
                    item.unit,
                    item.lastUpdated,
                  ]).toList(),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupplierReport() {
    return FutureBuilder<List<SupplierTransaction>>(
      future: LocalRepository.instance.getSupplierTransactions(),
      builder: (context, snapshot) {
        print('🔍 Supplier Report - Connection state: ${snapshot.connectionState}');
        print('🔍 Supplier Report - Has data: ${snapshot.hasData}');
        print('🔍 Supplier Report - Has error: ${snapshot.hasError}');
        
        if (snapshot.hasError) {
          print('🔍 Supplier Report - Error: ${snapshot.error}');
          return _buildErrorState('Error loading supplier transactions: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final transactions = snapshot.data ?? [];
        print('🔍 Supplier Report - Transactions count: ${transactions.length}');
        
        if (transactions.isEmpty) {
          return _buildEmptyState(
            Icons.business,
            'No Supplier Transactions',
            'Record supplier transactions to track your purchases.',
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveUtils.getPadding(context),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportHeader('Supplier Transactions Report', transactions.length),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                _buildDataTable(
                  ['Date', 'Supplier', 'Item', 'Quantity', 'Amount'],
                  transactions.map((transaction) => [
                    transaction.date,
                    transaction.supplierName,
                    transaction.itemName,
                    '${transaction.quantity} ${transaction.unit}',
                    '₱${transaction.amount.toStringAsFixed(2)}',
                  ]).toList(),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportOptions() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPadding(context),
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getMaxContentWidth(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
            Text(
              'Export your data in various formats for analysis and reporting',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 16),
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 30)),
            _buildExportCard(
              'Export All Data',
              'Export all records in CSV format',
              Icons.file_download,
              const Color(0xFF4CAF50),
              () => _exportAllData(),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
            _buildExportCard(
              'Export Sugar Records',
              'Export sugarcane monitoring data only',
              Icons.agriculture,
              const Color(0xFF2196F3),
              () => _exportSugarRecords(),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
            _buildExportCard(
              'Export Inventory',
              'Export inventory data only',
              Icons.inventory_2,
              const Color(0xFFFF9800),
              () => _exportInventory(),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
            _buildExportCard(
              'Export Suppliers',
              'Export supplier transaction data only',
              Icons.business,
              const Color(0xFF9C27B0),
              () => _exportSuppliers(),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: ResponsiveUtils.getPadding(context),
                child: isMobile && isSmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 10)),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: ResponsiveUtils.getIconSize(context, 20),
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: color,
                                size: ResponsiveUtils.getIconSize(context, 14),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 12),
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: ResponsiveUtils.getIconSize(context, 24),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getFontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: color,
                            size: ResponsiveUtils.getIconSize(context, 16),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportHeader(String title, int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          padding: ResponsiveUtils.getPadding(context),
          child: isMobile && isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$count records found',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getSpacing(context, 12),
                            vertical: ResponsiveUtils.getSpacing(context, 6),
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: $count',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.getFontSize(context, 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 20),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                          Text(
                            '$count records found',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 14),
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getSpacing(context, 16),
                        vertical: ResponsiveUtils.getSpacing(context, 8),
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total: $count',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDataTable(List<String> headers, List<List<String>> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          margin: ResponsiveUtils.getHorizontalPadding(context),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal scrollable table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth - ResponsiveUtils.getSpacing(context, 32),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Colors.white.withValues(alpha: 0.1),
                    ),
                    dataRowColor: WidgetStateProperty.all(Colors.transparent),
                    headingTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.getFontSize(context, isSmallScreen ? 11 : 14),
                    ),
                    dataTextStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: ResponsiveUtils.getFontSize(context, isSmallScreen ? 10 : 13),
                    ),
                    columnSpacing: isMobile ? 16 : 24,
                    columns: headers.map((header) => DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getSpacing(context, 8),
                        ),
                        child: Text(
                          header,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )).toList(),
                    rows: rows.map((row) => DataRow(
                      cells: row.map((cell) => DataCell(
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.getSpacing(context, 4),
                          ),
                          child: Text(
                            cell,
                            maxLines: isMobile ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )).toList(),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String description) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh the data by rebuilding the widget
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllData() async {
    // Show selection dialog first
    final exportOptions = await _showExportSelectionDialog();
    
    if (exportOptions == null) {
      return; // User cancelled
    }

    try {
      HapticFeedback.lightImpact();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              Text(
                'Exporting data...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      );

      final results = await DataExportService.exportSelectedData(
        exportSugarRecords: exportOptions['sugar'] ?? false,
        exportInventory: exportOptions['inventory'] ?? false,
        exportSuppliers: exportOptions['suppliers'] ?? false,
        exportAlerts: exportOptions['alerts'] ?? false,
      );
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog with share option
      if (mounted) {
        DataExportService.showExportSuccessDialog(context, results);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _exportSugarRecords() async {
    try {
      HapticFeedback.lightImpact();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              Text(
                'Exporting sugar records...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      );

      final results = await DataExportService.exportSelectedData(
        exportSugarRecords: true,
        exportInventory: false,
        exportSuppliers: false,
        exportAlerts: false,
      );
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog with share option
      if (mounted) {
        DataExportService.showExportSuccessDialog(context, results);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _exportInventory() async {
    try {
      HapticFeedback.lightImpact();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              Text(
                'Exporting inventory data...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      );

      final results = await DataExportService.exportSelectedData(
        exportSugarRecords: false,
        exportInventory: true,
        exportSuppliers: false,
        exportAlerts: false,
      );
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog with share option
      if (mounted) {
        DataExportService.showExportSuccessDialog(context, results);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _exportSuppliers() async {
    try {
      HapticFeedback.lightImpact();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              Text(
                'Exporting supplier data...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      );

      final results = await DataExportService.exportSelectedData(
        exportSugarRecords: false,
        exportInventory: false,
        exportSuppliers: true,
        exportAlerts: false,
      );
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog with share option
      if (mounted) {
        DataExportService.showExportSuccessDialog(context, results);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<Map<String, bool>?> _showExportSelectionDialog() async {
    final constants = Constants();
    bool exportSugar = true;
    bool exportInventory = true;
    bool exportSuppliers = true;
    bool exportAlerts = false;

    final result = await showResponsiveDialog<Map<String, bool>>(
      context: context,
      title: 'Select Data to Export',
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose which data types you want to export:',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                _buildExportOption(
                  context,
                  'Sugar Records',
                  'Export all sugarcane farming records',
                  Icons.agriculture_rounded,
                  exportSugar,
                  (value) => setState(() => exportSugar = value),
                  constants,
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                _buildExportOption(
                  context,
                  'Inventory Items',
                  'Export all inventory items and quantities',
                  Icons.inventory_2_rounded,
                  exportInventory,
                  (value) => setState(() => exportInventory = value),
                  constants,
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                _buildExportOption(
                  context,
                  'Supplier Transactions',
                  'Export all supplier purchase records',
                  Icons.business_rounded,
                  exportSuppliers,
                  (value) => setState(() => exportSuppliers = value),
                  constants,
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                _buildExportOption(
                  context,
                  'Alerts',
                  'Export all system alerts and notifications',
                  Icons.notifications_rounded,
                  exportAlerts,
                  (value) => setState(() => exportAlerts = value),
                  constants,
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                if (!exportSugar && !exportInventory && !exportSuppliers && !exportAlerts)
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: ResponsiveUtils.getIconSize(context, 20)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Expanded(
                          child: Text(
                            'Please select at least one data type to export.',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 12),
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (exportSugar || exportInventory || exportSuppliers || exportAlerts) {
              Navigator.pop(context, {
                'sugar': exportSugar,
                'inventory': exportInventory,
                'suppliers': exportSuppliers,
                'alerts': exportAlerts,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: constants.sugarcanePrimaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Export'),
        ),
      ],
    );

    return result;
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    Constants constants,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 14),
          ),
        ),
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
        secondary: Icon(
          icon,
          color: constants.sugarcanePrimaryColor,
          size: ResponsiveUtils.getIconSize(context, 24),
        ),
        activeColor: constants.sugarcanePrimaryColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getSpacing(context, 12),
          vertical: ResponsiveUtils.getSpacing(context, 4),
        ),
      ),
    );
  }

  Widget _buildSugarStatistics(List<SugarRecord> records) {
    if (records.isEmpty) return const SizedBox.shrink();
    
    final averageHeight = records.map((r) => r.heightCm).reduce((a, b) => a + b) / records.length;
    final maxHeight = records.map((r) => r.heightCm).reduce((a, b) => a > b ? a : b);
    final minHeight = records.map((r) => r.heightCm).reduce((a, b) => a < b ? a : b);
    final varieties = records.map((r) => r.variety).toSet().length;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          margin: ResponsiveUtils.getHorizontalPadding(context),
          padding: ResponsiveUtils.getPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50).withValues(alpha: 0.2),
                const Color(0xFF4CAF50).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
          ),
          child: isMobile && isSmallScreen
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Avg Height', '${averageHeight.toStringAsFixed(1)} cm', Icons.height)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Expanded(child: _buildStatItem('Max Height', '$maxHeight cm', Icons.trending_up)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Min Height', '$minHeight cm', Icons.trending_down)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Expanded(child: _buildStatItem('Varieties', '$varieties', Icons.grass)),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildStatItem('Avg Height', '${averageHeight.toStringAsFixed(1)} cm', Icons.height)),
                    Expanded(child: _buildStatItem('Max Height', '$maxHeight cm', Icons.trending_up)),
                    Expanded(child: _buildStatItem('Min Height', '$minHeight cm', Icons.trending_down)),
                    Expanded(child: _buildStatItem('Varieties', '$varieties', Icons.grass)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildInventoryStatistics(List<InventoryItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    final totalItems = items.length;
    final lowStockItems = items.where((item) => item.quantity <= 10).length;
    final categories = items.map((item) => item.category).toSet().length;
    final totalQuantity = items.map((item) => item.quantity).reduce((a, b) => a + b);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Container(
          margin: ResponsiveUtils.getHorizontalPadding(context),
          padding: ResponsiveUtils.getPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2196F3).withValues(alpha: 0.2),
                const Color(0xFF2196F3).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
          ),
          child: isMobile && isSmallScreen
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Total Items', '$totalItems', Icons.inventory_2)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Expanded(child: _buildStatItem('Low Stock', '$lowStockItems', Icons.warning)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Categories', '$categories', Icons.category)),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                        Expanded(child: _buildStatItem('Total Qty', '$totalQuantity', Icons.numbers)),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildStatItem('Total Items', '$totalItems', Icons.inventory_2)),
                    Expanded(child: _buildStatItem('Low Stock', '$lowStockItems', Icons.warning)),
                    Expanded(child: _buildStatItem('Categories', '$categories', Icons.category)),
                    Expanded(child: _buildStatItem('Total Qty', '$totalQuantity', Icons.numbers)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = ResponsiveUtils.isSmallMobile(context);
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: ResponsiveUtils.getIconSize(context, isSmallScreen ? 18 : 20),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, isSmallScreen ? 14 : 16),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 2)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, isSmallScreen ? 10 : 12),
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
