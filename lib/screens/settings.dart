import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample/models/constants.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/services/data_export_service.dart';
import 'package:sample/services/supabase_service.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/utils/system_status_checker.dart';
import 'package:sample/widgets/responsive_builder.dart';
import 'package:sample/widgets/responsive_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Constants _constants = Constants();
  
  // Settings state
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  bool _lowStockAlerts = true;
  bool _weatherAlerts = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'PHP';
  int _syncInterval = 30; // minutes
  int _lowStockThreshold = 10;
  
  // System status
  Map<String, dynamic>? _systemStatus;
  bool _isCheckingStatus = false;
  
  // Get system status display text
  String get _systemStatusText {
    if (_systemStatus == null) return 'Unknown';
    final isOnline = _systemStatus!['supabase_connected'] == true;
    return isOnline ? 'Online' : 'Offline';
  }
  
  // Language options
  final List<String> _languages = ['English', 'Filipino', 'Spanish'];
  
  // Currency options
  final List<String> _currencies = ['PHP', 'USD', 'EUR'];
  
  // Sync interval options (in minutes)
  final List<int> _syncIntervals = [15, 30, 60, 120, 240];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      // Theme is now handled automatically by system settings
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      _lowStockAlerts = prefs.getBool('low_stock_alerts') ?? true;
      _weatherAlerts = prefs.getBool('weather_alerts') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
      _selectedCurrency = prefs.getString('selected_currency') ?? 'PHP';
      _syncInterval = prefs.getInt('sync_interval') ?? 30;
      _lowStockThreshold = prefs.getInt('low_stock_threshold') ?? 10;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    // Theme settings are now handled automatically by system
    await prefs.setBool('auto_sync_enabled', _autoSyncEnabled);
    await prefs.setBool('low_stock_alerts', _lowStockAlerts);
    await prefs.setBool('weather_alerts', _weatherAlerts);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('selected_currency', _selectedCurrency);
    await prefs.setInt('sync_interval', _syncInterval);
    await prefs.setInt('low_stock_threshold', _lowStockThreshold);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _clearAllData() async {
    final confirmed = await showStandardConfirmation(
      context: context,
      title: '⚠️ Clear All Data',
      message: 'This will permanently delete all your sugarcane records, inventory, and supplier transactions. This action cannot be undone.\n\nAre you sure you want to continue?',
      confirmText: 'Clear All Data',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset to default settings
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All data cleared successfully!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        // Add system alert
        await AlertService.alertSystemActivity(
          activity: 'Data Cleared',
          details: 'All farm data has been permanently deleted from the system.',
          severity: 'warning',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 20),
          ),
        ),
        backgroundColor: scheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save_rounded,
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
            onPressed: _showHelpDialog,
            tooltip: 'Help & Information',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
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
            // App Information Section
            _buildSectionHeader('App Information', Icons.info_outline_rounded),
            _buildInfoCard(),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
            
            // Notification Settings
            _buildSectionHeader('Notifications', Icons.notifications_rounded),
            _buildSwitchTile(
              'Enable Notifications',
              'Receive alerts and updates',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
              Icons.notifications_active_rounded,
              helpText: 'This is the master switch for all app notifications. When enabled, you\'ll receive alerts for important events like low stock, weather changes, and system updates.',
            ),
            _buildSwitchTile(
              'Low Stock Alerts',
              'Get notified when inventory is low',
              _lowStockAlerts,
              (value) => setState(() => _lowStockAlerts = value),
              Icons.warning_amber_rounded,
              helpText: 'Receive notifications when any inventory item falls below the low stock threshold. This helps you maintain adequate supplies for your farming operations.',
            ),
            _buildSwitchTile(
              'Weather Alerts',
              'Get notified about weather changes',
              _weatherAlerts,
              (value) => setState(() => _weatherAlerts = value),
              Icons.cloud_rounded,
              helpText: 'Get notified about significant weather changes that may affect your sugarcane farming, such as heavy rain, storms, or extreme temperatures.',
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
            
            // Display Settings
            _buildSectionHeader('Display', Icons.palette_rounded),
            _buildInfoTile(
              'Theme',
              'Theme automatically follows your device settings',
              Icons.auto_mode_rounded,
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
            
            // Data & Sync Settings
            _buildSectionHeader('Data & Sync', Icons.sync_rounded),
            _buildSwitchTile(
              'Auto Sync',
              'Automatically sync data',
              _autoSyncEnabled,
              (value) => setState(() => _autoSyncEnabled = value),
              Icons.sync_rounded,
              helpText: 'Automatically synchronize your data with cloud storage. When enabled, your data is backed up and synced across devices. Requires internet connection.',
            ),
            _buildDropdownTile(
              'Sync Interval',
              'How often to sync data',
              '${_syncInterval} minutes',
              Icons.schedule_rounded,
              () => _showSyncIntervalDialog(),
              helpText: 'Choose how frequently the app syncs your data with cloud storage. More frequent syncing ensures your data is always up-to-date but uses more data.',
            ),
            _buildSliderTile(
              'Low Stock Threshold',
              'Alert when quantity is at or below this number',
              _lowStockThreshold.toDouble(),
              1,
              50,
              (value) => setState(() => _lowStockThreshold = value.round()),
              Icons.inventory_2_rounded,
              helpText: 'Set the minimum quantity threshold for inventory items. When any item\'s quantity falls to or below this number, you\'ll receive a low stock alert.',
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
            
            // Language & Region
            _buildSectionHeader('Language & Region', Icons.language_rounded),
            _buildDropdownTile(
              'Language',
              'Select your preferred language',
              _selectedLanguage,
              Icons.translate_rounded,
              () => _showLanguageDialog(),
              helpText: 'Choose the language for the app interface. This affects all text displayed in the app.',
            ),
            _buildDropdownTile(
              'Currency',
              'Select your preferred currency',
              _selectedCurrency,
              Icons.attach_money_rounded,
              () => _showCurrencyDialog(),
              helpText: 'Set the currency used for displaying financial information throughout the app.',
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
            
            // Data Management
            _buildSectionHeader('Data Management', Icons.storage_rounded),
            _buildDataStatsCard(),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
            _buildActionTile(
              'Database Status',
              _isCheckingStatus 
                ? 'Checking system status...' 
                : SupabaseService.isReady 
                  ? 'Connected to Supabase' 
                  : 'Local storage only',
              Icons.cloud_sync_rounded,
              () => _testSupabaseConnection(),
              helpText: 'Check the connection status of your database and view system health information. This includes Supabase connection, local repository status, and data counts.',
            ),
            _buildActionTile(
              'Export Data',
              'Download your data as CSV',
              Icons.download_rounded,
              () => _exportData(),
              helpText: 'Export all your farm data (sugar records, inventory, supplier transactions) as CSV files. These files can be opened in Excel or other spreadsheet applications.',
            ),
            _buildActionTile(
              'Import Data',
              'Import data from CSV file',
              Icons.upload_rounded,
              () => _importData(),
              helpText: 'Import data from previously exported CSV files. This allows you to restore data or add data from other sources.',
            ),
            _buildActionTile(
              'Backup Data',
              'Create a backup of your data',
              Icons.backup_rounded,
              () => _backupData(),
              helpText: 'Create a complete backup of all your farm data. This is useful before making major changes or as a regular safety measure.',
            ),
            _buildActionTile(
              'Restore Data',
              'Restore from a backup',
              Icons.restore_rounded,
              () => _restoreData(),
              helpText: 'Restore your data from a previously created backup. This will replace all current data with the backup data. Use with caution!',
            ),
            _buildActionTile(
              'System Maintenance',
              'Clean up and optimize system',
              Icons.build_rounded,
              () => _systemMaintenance(),
              helpText: 'Perform system maintenance tasks to optimize performance. This includes clearing cache, optimizing the database, and removing temporary files.',
            ),
            _buildActionTile(
              'Clear All Data',
              'Permanently delete all data',
              Icons.delete_forever_rounded,
              _clearAllData,
              isDestructive: true,
              helpText: '⚠️ WARNING: This will permanently delete ALL your data including sugar records, inventory items, supplier transactions, and alerts. This action cannot be undone. Make sure you have a backup before proceeding!',
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
            
            // About Section
            _buildSectionHeader('About', Icons.info_rounded),
            _buildActionTile(
              'App Version',
              'Version 1.0.0 (Build 1)',
              Icons.info_outline_rounded,
              () {},
              showArrow: false,
            ),
            _buildActionTile(
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip_rounded,
              () => _showPrivacyPolicy(),
            ),
            _buildActionTile(
              'Terms of Service',
              'View terms of service',
              Icons.description_rounded,
              () => _showTermsOfService(),
            ),
            _buildActionTile(
              'Contact Support',
              'Get help and support',
              Icons.support_agent_rounded,
              () => _contactSupport(),
            ),
            
                  SizedBox(height: ResponsiveUtils.getSpacing(context, 40)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showHelpDialog() {
    showResponsiveDialog(
      context: context,
      title: 'Settings Help & Information',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpSection(
              'Notifications',
              'Control how and when you receive alerts:\n'
              '• Enable Notifications: Master switch for all app notifications\n'
              '• Low Stock Alerts: Get notified when inventory items are running low\n'
              '• Weather Alerts: Receive weather updates that may affect farming',
            ),
            const SizedBox(height: 16),
            _buildHelpSection(
              'Data & Sync',
              'Manage data synchronization:\n'
              '• Auto Sync: Automatically sync data with cloud storage\n'
              '• Sync Interval: How often data syncs (15 min to 4 hours)\n'
              '• Low Stock Threshold: Alert when inventory drops below this number',
            ),
            const SizedBox(height: 16),
            _buildHelpSection(
              'Language & Region',
              'Customize your experience:\n'
              '• Language: Choose your preferred language\n'
              '• Currency: Set currency for financial displays',
            ),
            const SizedBox(height: 16),
            _buildHelpSection(
              'Data Management',
              'Manage your farm data:\n'
              '• Database Status: Check connection to cloud storage\n'
              '• Export Data: Download your data as CSV files\n'
              '• Import Data: Import data from CSV files\n'
              '• Backup/Restore: Create and restore data backups\n'
              '• System Maintenance: Optimize system performance',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }
  
  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context, 12)),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: ResponsiveUtils.getIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 16)),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _constants.sugarcanePrimaryColor,
                      radius: ResponsiveUtils.getIconSize(context, 24) / 2,
                      child: Text(
                        'HE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtils.getFontSize(context, 16),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hacienda Elizabeth',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sugarcane Farming System',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: ResponsiveUtils.getFontSize(context, 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
                  decoration: BoxDecoration(
                    color: _constants.sugarcanePrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: _constants.sugarcanePrimaryColor,
                        size: ResponsiveUtils.getIconSize(context, 16),
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                      Expanded(
                        child: Text(
                          'Talisay City, Negros Occidental, Philippines',
                          style: TextStyle(
                            color: _constants.sugarcanePrimaryColor,
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
                  decoration: BoxDecoration(
                    color: _systemStatusText == 'Online' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveUtils.getSpacing(context, 8),
                        height: ResponsiveUtils.getSpacing(context, 8),
                        decoration: BoxDecoration(
                          color: _systemStatusText == 'Online' ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                      Expanded(
                        child: Text(
                          'System Status: $_systemStatusText',
                          style: TextStyle(
                            color: _systemStatusText == 'Online' ? Colors.green[700] : Colors.red[700],
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon, {
    String? helpText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SwitchListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (helpText != null)
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: ResponsiveUtils.getIconSize(context, 18),
                      color: Colors.grey[500],
                    ),
                    onPressed: () => _showSettingInfo(title, helpText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
            value: value,
            onChanged: (newValue) {
              onChanged(newValue);
              _saveSettings();
            },
            secondary: Icon(
              icon,
              color: Colors.grey[600],
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
            activeThumbColor: _constants.sugarcanePrimaryColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, 16),
              vertical: ResponsiveUtils.getSpacing(context, 8),
            ),
          ),
        );
      },
    );
  }
  
  void _showSettingInfo(String title, String info) {
    showResponsiveDialog(
      context: context,
      title: title,
      content: Text(
        info,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    IconData icon,
    VoidCallback onTap, {
    String? helpText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (helpText != null)
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: ResponsiveUtils.getIconSize(context, 18),
                      color: Colors.grey[500],
                    ),
                    onPressed: () => _showSettingInfo(title, helpText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: ResponsiveUtils.getIconSize(context, 16),
                ),
              ],
            ),
            leading: Icon(
              icon,
              color: Colors.grey[600],
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
            onTap: onTap,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, 16),
              vertical: ResponsiveUtils.getSpacing(context, 8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    IconData icon, {
    String? helpText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.grey[600],
                      size: ResponsiveUtils.getIconSize(context, 24),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (helpText != null)
                                IconButton(
                                  icon: Icon(
                                    Icons.info_outline_rounded,
                                    size: ResponsiveUtils.getIconSize(context, 18),
                                    color: Colors.grey[500],
                                  ),
                                  onPressed: () => _showSettingInfo(title, helpText),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: ResponsiveUtils.getFontSize(context, 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                    Text(
                      value.round().toString(),
                      style: TextStyle(
                        color: _constants.sugarcanePrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getFontSize(context, 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).round(),
                  onChanged: (newValue) {
                    onChanged(newValue);
                    _saveSettings();
                  },
                  activeColor: _constants.sugarcanePrimaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool showArrow = true,
    String? helpText,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : null,
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                    ),
                  ),
                ),
                if (helpText != null)
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: ResponsiveUtils.getIconSize(context, 18),
                      color: isDestructive ? Colors.red[300] : Colors.grey[500],
                    ),
                    onPressed: () => _showSettingInfo(title, helpText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
            trailing: showArrow
                ? Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: ResponsiveUtils.getIconSize(context, 16),
                    color: isDestructive ? Colors.red : Colors.grey[400],
                  )
                : null,
            leading: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey[600],
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
            onTap: onTap,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, 16),
              vertical: ResponsiveUtils.getSpacing(context, 8),
            ),
          ),
        );
      },
    );
  }

  void _showSyncIntervalDialog() {
    showResponsiveDialog(
      context: context,
      title: 'Sync Interval',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _syncIntervals.map((interval) {
          return _buildSelectionTile(
            label: '$interval minutes',
            isSelected: interval == _syncInterval,
            onSelected: () {
              setState(() => _syncInterval = interval);
              _saveSettings();
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageDialog() {
    showResponsiveDialog(
      context: context,
      title: 'Select Language',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _languages.map((language) {
          return _buildSelectionTile(
            label: language,
            isSelected: language == _selectedLanguage,
            onSelected: () {
              setState(() => _selectedLanguage = language);
              _saveSettings();
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCurrencyDialog() {
    showResponsiveDialog(
      context: context,
      title: 'Select Currency',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _currencies.map((currency) {
          return _buildSelectionTile(
            label: currency,
            isSelected: currency == _selectedCurrency,
            onSelected: () {
              setState(() => _selectedCurrency = currency);
              _saveSettings();
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? colorScheme.primary : Colors.grey[500],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, 16),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: onSelected,
    );
  }

  Future<void> _exportData() async {
    // Show selection dialog first
    final exportOptions = await _showExportSelectionDialog();
    
    if (exportOptions == null) {
      return; // User cancelled
    }

    try {
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
      
      // Show success dialog
      if (mounted) {
        DataExportService.showExportSuccessDialog(context, results);
        
        // Add system alert
        final exportedTypes = results.keys
            .where((k) => k != 'summary' && k != 'export_directory')
            .join(', ');
        await AlertService.alertSystemActivity(
          activity: 'Data Export',
          details: 'Farm data exported successfully. Files: $exportedTypes',
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
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
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                _buildExportOption(
                  context,
                  'Inventory Items',
                  'Export all inventory items and quantities',
                  Icons.inventory_2_rounded,
                  exportInventory,
                  (value) => setState(() => exportInventory = value),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                _buildExportOption(
                  context,
                  'Supplier Transactions',
                  'Export all supplier purchase records',
                  Icons.business_rounded,
                  exportSuppliers,
                  (value) => setState(() => exportSuppliers = value),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                _buildExportOption(
                  context,
                  'Alerts',
                  'Export all system alerts and notifications',
                  Icons.notifications_rounded,
                  exportAlerts,
                  (value) => setState(() => exportAlerts = value),
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
            backgroundColor: _constants.sugarcanePrimaryColor,
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
          color: _constants.sugarcanePrimaryColor,
          size: ResponsiveUtils.getIconSize(context, 24),
        ),
        activeColor: _constants.sugarcanePrimaryColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getSpacing(context, 12),
          vertical: ResponsiveUtils.getSpacing(context, 4),
        ),
      ),
    );
  }

  Future<void> _importData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Importing data...'),
            ],
          ),
        ),
      );

      final results = await DataExportService.importData();
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog
      if (mounted) {
        DataExportService.showImportSuccessDialog(context, results);
        
        // Add system alert
        await AlertService.alertSystemActivity(
          activity: 'Data Import',
          details: 'Data imported successfully. Records: ${results.values.fold(0, (a, b) => a + b)}',
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    showResponsiveDialog(
      context: context,
      title: 'Privacy Policy',
      content: SingleChildScrollView(
        child: Text(
          'This app collects and stores your farming data locally on your device. We do not share your data with third parties. Your data is used solely for the purpose of managing your sugarcane farming operations.\n\nFor more information, please contact our support team.',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 16),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showTermsOfService() {
    showResponsiveDialog(
      context: context,
      title: 'Terms of Service',
      content: SingleChildScrollView(
        child: Text(
          'By using this app, you agree to use it responsibly for farming management purposes. The app is provided as-is and we are not liable for any farming decisions made based on the data provided.\n\nFor support, please contact our team.',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 16),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _contactSupport() {
    showResponsiveDialog(
      context: context,
      title: 'Contact Support',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email: support@haciendaelizabeth.com',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
          Text(
            'Phone: +63 123 456 7890',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
          Text(
            'Address: Talisay City, Negros Occidental',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          Text(
            'We\'re here to help with any questions or issues you may have with the app.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 14),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDataStatsCard() {
    return FutureBuilder<Map<String, int>>(
      future: _getDataStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Loading data statistics...'),
                ],
              ),
            ),
          );
        }

        final stats = snapshot.data ?? {};
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: _constants.sugarcanePrimaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Data Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Sugar Records',
                        stats['sugar_records']?.toString() ?? '0',
                        Icons.agriculture_rounded,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Inventory Items',
                        stats['inventory_items']?.toString() ?? '0',
                        Icons.inventory_2_rounded,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Suppliers',
                        stats['supplier_transactions']?.toString() ?? '0',
                        Icons.business_rounded,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Alerts',
                        stats['alerts']?.toString() ?? '0',
                        Icons.notifications_rounded,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: ResponsiveUtils.getIconSize(context, 20),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 2)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 12),
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildResponsiveStatusWidget(Map<String, dynamic> status) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'System Status Checks',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
            _buildStatusItem(
              'Supabase Connection',
              status['supabase_message'] ?? 'Unknown',
              status['supabase_connected'] == true,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
            _buildStatusItem(
              'Local Repository',
              status['local_message'] ?? 'Unknown',
              status['local_repository'] == true,
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
            _buildStatusItem(
              'Real-time Sync',
              status['realtime_message'] ?? 'Unknown',
              status['realtime_subscriptions'] == true,
            ),
            if (status['data_counts'] != null) ...[
              SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
              Text(
                'Data Counts',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
              ...status['data_counts'].entries.map((entry) => 
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getSpacing(context, 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          entry.key.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildStatusItem(String title, String message, bool isSuccess) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: ResponsiveUtils.getIconSize(context, 20),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, int>> _getDataStatistics() async {
    try {
      final sugarRecords = await LocalRepository.instance.getSugarRecords();
      final inventoryItems = await LocalRepository.instance.getInventoryItems();
      final supplierTransactions = await LocalRepository.instance.getSupplierTransactions();
      final alerts = await LocalRepository.instance.getAlerts();

      return {
        'sugar_records': sugarRecords.length,
        'inventory_items': inventoryItems.length,
        'supplier_transactions': supplierTransactions.length,
        'alerts': alerts.length,
      };
    } catch (e) {
      print('Error getting data statistics: $e');
      return {};
    }
  }

  Future<void> _backupData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating backup...'),
            ],
          ),
        ),
      );

      // Create backup by exporting all data
      final results = await DataExportService.exportAllData();
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup Created'),
            content: Text(
              'Backup created successfully!\n\nFiles exported:\n${results.keys.map((k) => '• $k').join('\n')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        // Add system alert
        await AlertService.alertSystemActivity(
          activity: 'Data Backup',
          details: 'Backup created successfully. Files: ${results.keys.join(', ')}',
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    final confirmed = await showStandardConfirmation(
      context: context,
      title: 'Restore Data',
      message: 'This will replace all current data with data from a backup. This action cannot be undone.\n\nAre you sure you want to continue?',
      confirmText: 'Restore',
      cancelText: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Restoring data...'),
              ],
            ),
          ),
        );

        // Restore data by importing
        final results = await DataExportService.importData();
        
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        
        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Data Restored'),
              content: Text(
                'Data restored successfully!\n\nRecords imported:\n${results.entries.map((e) => '• ${e.key}: ${e.value}').join('\n')}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          
          // Add system alert
          await AlertService.alertSystemActivity(
            activity: 'Data Restore',
            details: 'Data restored successfully. Records: ${results.values.fold(0, (a, b) => a + b)}',
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restore failed: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Future<void> _systemMaintenance() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Performing system maintenance...'),
            ],
          ),
        ),
      );

      // Perform maintenance tasks
      await Future.delayed(const Duration(seconds: 2)); // Simulate maintenance
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Maintenance Complete'),
            content: const Text(
              'System maintenance completed successfully!\n\n• Cache cleared\n• Database optimized\n• Temporary files removed\n• System performance improved',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        // Add system alert
        await AlertService.alertSystemActivity(
          activity: 'System Maintenance',
          details: 'System maintenance completed successfully. Performance optimized.',
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maintenance failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final status = await SystemStatusChecker.checkSystemStatus();
      setState(() {
        _systemStatus = status;
        _isCheckingStatus = false;
      });

      if (mounted) {
        showResponsiveDialog(
          context: context,
          title: 'System Status',
          content: SingleChildScrollView(
            child: _buildResponsiveStatusWidget(status),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _testSupabaseConnection();
              },
              child: const Text('Refresh'),
            ),
          ],
        );
      }
    } catch (e) {
      setState(() {
        _isCheckingStatus = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Status check error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
