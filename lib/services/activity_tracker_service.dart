import 'dart:async';
import 'package:flutter/foundation.dart';

enum ActivityType {
  sugarRecordAdded,
  sugarRecordUpdated,
  sugarRecordDeleted,
  inventoryItemAdded,
  inventoryItemUpdated,
  inventoryItemDeleted,
  supplierTransactionAdded,
  supplierTransactionUpdated,
  supplierTransactionDeleted,
  alertCreated,
  alertRead,
  dataExported,
  dataImported,
  systemBackup,
  userLogin,
  userLogout,
  settingsChanged,
}

class ActivityEvent {
  final String id;
  final ActivityType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final bool isRead;

  ActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.metadata,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      id: json['id'],
      type: ActivityType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
    );
  }

  ActivityEvent copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) {
    return ActivityEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ActivityTrackerService {
  static final ActivityTrackerService _instance = ActivityTrackerService._internal();
  factory ActivityTrackerService() => _instance;
  ActivityTrackerService._internal();

  final StreamController<List<ActivityEvent>> _activitiesController = 
      StreamController<List<ActivityEvent>>.broadcast();
  
  final List<ActivityEvent> _activities = [];
  Timer? _cleanupTimer;

  Stream<List<ActivityEvent>> get activitiesStream => _activitiesController.stream;
  
  List<ActivityEvent> get activities => List.unmodifiable(_activities);
  
  int get unreadCount => _activities.where((activity) => !activity.isRead).length;

  void initialize() {
    _startCleanupTimer();
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _activitiesController.close();
  }

  void trackActivity(ActivityType type, String title, String message, {Map<String, dynamic>? metadata}) {
    final activity = ActivityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _activities.insert(0, activity); // Add to beginning for newest first
    
    // Keep only last 100 activities to prevent memory issues
    if (_activities.length > 100) {
      _activities.removeRange(100, _activities.length);
    }

    _activitiesController.add(List.unmodifiable(_activities));
    
    if (kDebugMode) {
      print('Activity tracked: $title - $message');
    }
  }

  void markAsRead(String activityId) {
    final index = _activities.indexWhere((activity) => activity.id == activityId);
    if (index != -1) {
      _activities[index] = _activities[index].copyWith(isRead: true);
      _activitiesController.add(List.unmodifiable(_activities));
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _activities.length; i++) {
      _activities[i] = _activities[i].copyWith(isRead: true);
    }
    _activitiesController.add(List.unmodifiable(_activities));
  }

  void clearOldActivities() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    _activities.removeWhere((activity) => activity.timestamp.isBefore(cutoffDate));
    _activitiesController.add(List.unmodifiable(_activities));
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      clearOldActivities();
    });
  }

  // Convenience methods for common activities
  void trackSugarRecordAdded(String variety, int height) {
    trackActivity(
      ActivityType.sugarRecordAdded,
      'New Sugar Record Added',
      'Added $variety variety with height ${height}cm',
      metadata: {'variety': variety, 'height': height},
    );
  }

  void trackSugarRecordUpdated(String variety, int height) {
    trackActivity(
      ActivityType.sugarRecordUpdated,
      'Sugar Record Updated',
      'Updated $variety variety to height ${height}cm',
      metadata: {'variety': variety, 'height': height},
    );
  }

  void trackInventoryItemAdded(String itemName, int quantity) {
    trackActivity(
      ActivityType.inventoryItemAdded,
      'Inventory Item Added',
      'Added $itemName with quantity $quantity',
      metadata: {'itemName': itemName, 'quantity': quantity},
    );
  }

  void trackInventoryItemUpdated(String itemName, int quantity) {
    trackActivity(
      ActivityType.inventoryItemUpdated,
      'Inventory Item Updated',
      'Updated $itemName quantity to $quantity',
      metadata: {'itemName': itemName, 'quantity': quantity},
    );
  }

  void trackSupplierTransactionAdded(String supplierName, double amount) {
    trackActivity(
      ActivityType.supplierTransactionAdded,
      'Supplier Transaction Added',
      'Added transaction with $supplierName for ₱${amount.toStringAsFixed(2)}',
      metadata: {'supplierName': supplierName, 'amount': amount},
    );
  }

  void trackDataExported(String dataType, int recordCount) {
    trackActivity(
      ActivityType.dataExported,
      'Data Exported',
      'Exported $recordCount $dataType records',
      metadata: {'dataType': dataType, 'recordCount': recordCount},
    );
  }

  void trackDataImported(String dataType, int recordCount) {
    trackActivity(
      ActivityType.dataImported,
      'Data Imported',
      'Imported $recordCount $dataType records',
      metadata: {'dataType': dataType, 'recordCount': recordCount},
    );
  }

  void trackSystemBackup() {
    trackActivity(
      ActivityType.systemBackup,
      'System Backup Created',
      'Automatic backup completed successfully',
    );
  }

  void trackSettingsChanged(String settingName) {
    trackActivity(
      ActivityType.settingsChanged,
      'Settings Updated',
      'Updated $settingName setting',
      metadata: {'settingName': settingName},
    );
  }

  void trackUserLogin(String username) {
    trackActivity(
      ActivityType.userLogin,
      'User Login',
      '$username logged into the system',
      metadata: {'username': username},
    );
  }

  void trackUserLogout(String username) {
    trackActivity(
      ActivityType.userLogout,
      'User Logout',
      '$username logged out of the system',
      metadata: {'username': username},
    );
  }
}
