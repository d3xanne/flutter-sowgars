import 'dart:convert';

class RealtimeEvent {
  final String id; // unique id
  final String entity; // sugar, inventory, supplier
  final String action; // add, update, delete
  final String message; // human-readable description
  final DateTime timestamp;

  RealtimeEvent({
    required this.id,
    required this.entity,
    required this.action,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'entity': entity,
        'action': action,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RealtimeEvent.fromMap(Map<String, dynamic> map) => RealtimeEvent(
        id: map['id'] as String,
        entity: map['entity'] as String,
        action: map['action'] as String,
        message: map['message'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  String toJson() => json.encode(toMap());
  factory RealtimeEvent.fromJson(String source) =>
      RealtimeEvent.fromMap(json.decode(source) as Map<String, dynamic>);
}
