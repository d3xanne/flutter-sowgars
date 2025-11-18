import 'dart:convert';

class SupplierTransaction {
  final String id;
  final String supplierName;
  final String itemName;
  final int quantity;
  final String unit;
  final double amount; // currency amount
  final String date; // yyyy-MM-dd
  final String notes;
  final bool archived; // New field for archiving
  final String? archivedAt; // When it was archived

  SupplierTransaction({
    required this.id,
    required this.supplierName,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.amount,
    required this.date,
    required this.notes,
    this.archived = false,
    this.archivedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_name': supplierName,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'amount': amount,
      'date': date,
      'notes': notes,
      'archived': archived,
      'archived_at': archivedAt,
    };
  }

  factory SupplierTransaction.fromMap(Map<String, dynamic> map) {
    return SupplierTransaction(
      id: map['id'] as String,
      supplierName: map['supplier_name'] as String,
      itemName: map['item_name'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unit: map['unit'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      notes: (map['notes'] ?? '') as String,
      archived: (map['archived'] ?? false) as bool,
      archivedAt: map['archived_at'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory SupplierTransaction.fromJson(String source) =>
      SupplierTransaction.fromMap(json.decode(source) as Map<String, dynamic>);

  SupplierTransaction copyWith({
    String? id,
    String? supplierName,
    String? itemName,
    int? quantity,
    String? unit,
    double? amount,
    String? date,
    String? notes,
    bool? archived,
    String? archivedAt,
  }) {
    return SupplierTransaction(
      id: id ?? this.id,
      supplierName: supplierName ?? this.supplierName,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}


