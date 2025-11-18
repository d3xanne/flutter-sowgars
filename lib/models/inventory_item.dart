import 'dart:convert';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final String lastUpdated; // yyyy-MM-dd

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lastUpdated,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    String? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'last_updated': lastUpdated,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unit: map['unit'] as String,
      lastUpdated: map['last_updated'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryItem.fromJson(String source) =>
      InventoryItem.fromMap(json.decode(source) as Map<String, dynamic>);
}


