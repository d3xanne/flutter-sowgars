import 'dart:convert';

class SugarRecord {
  final String id;
  final String date; // yyyy-MM-dd
  final String variety;
  final String soilTest;
  final String fertilizer;
  final int heightCm;
  final String notes;

  SugarRecord({
    required this.id,
    required this.date,
    required this.variety,
    required this.soilTest,
    required this.fertilizer,
    required this.heightCm,
    required this.notes,
  });

  SugarRecord copyWith({
    String? id,
    String? date,
    String? variety,
    String? soilTest,
    String? fertilizer,
    int? heightCm,
    String? notes,
  }) {
    return SugarRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      variety: variety ?? this.variety,
      soilTest: soilTest ?? this.soilTest,
      fertilizer: fertilizer ?? this.fertilizer,
      heightCm: heightCm ?? this.heightCm,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'variety': variety,
      'soil_test': soilTest,
      'fertilizer': fertilizer,
      'height_cm': heightCm,
      'notes': notes,
    };
  }

  factory SugarRecord.fromMap(Map<String, dynamic> map) {
    return SugarRecord(
      id: map['id'] as String,
      date: map['date'] as String,
      variety: map['variety'] as String,
      soilTest: map['soil_test'] as String,
      fertilizer: map['fertilizer'] as String,
      heightCm: (map['height_cm'] as num).toInt(),
      notes: (map['notes'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SugarRecord.fromJson(String source) =>
      SugarRecord.fromMap(json.decode(source) as Map<String, dynamic>);
}


