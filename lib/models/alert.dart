import 'dart:convert';

class AlertItem {
  final String id;
  final String title;
  final String message;
  final String severity; // info, warning, error
  final DateTime timestamp;
  final bool read;

  AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.read = false,
  });

  AlertItem copyWith({
    String? id,
    String? title,
    String? message,
    String? severity,
    DateTime? timestamp,
    bool? read,
  }) {
    return AlertItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'severity': severity,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };

  factory AlertItem.fromMap(Map<String, dynamic> map) => AlertItem(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        severity: map['severity'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        read: (map['read'] as bool?) ?? false,
      );

  String toJson() => json.encode(toMap());
  factory AlertItem.fromJson(String source) =>
      AlertItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
