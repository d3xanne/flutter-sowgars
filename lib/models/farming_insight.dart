import 'dart:convert';
import 'package:sample/utils/number_converter.dart';

class FarmingInsight {
  final String id;
  final String title;
  final String variety;
  final String waterRequirement;
  final String bestPlantingMonth;
  final String harvestEstimation;
  final String fertilizerType;
  final String fertilizerAmount;
  final double estimatedIncome;
  final double totalCost;
  final double netProfit;
  final String soilType;
  final String climateZone;
  final String recommendations;
  final String createdAt;
  final String updatedAt;

  FarmingInsight({
    required this.id,
    required this.title,
    required this.variety,
    required this.waterRequirement,
    required this.bestPlantingMonth,
    required this.harvestEstimation,
    required this.fertilizerType,
    required this.fertilizerAmount,
    required this.estimatedIncome,
    required this.totalCost,
    required this.netProfit,
    required this.soilType,
    required this.climateZone,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  FarmingInsight copyWith({
    String? id,
    String? title,
    String? variety,
    String? waterRequirement,
    String? bestPlantingMonth,
    String? harvestEstimation,
    String? fertilizerType,
    String? fertilizerAmount,
    double? estimatedIncome,
    double? totalCost,
    double? netProfit,
    String? soilType,
    String? climateZone,
    String? recommendations,
    String? createdAt,
    String? updatedAt,
  }) {
    return FarmingInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      variety: variety ?? this.variety,
      waterRequirement: waterRequirement ?? this.waterRequirement,
      bestPlantingMonth: bestPlantingMonth ?? this.bestPlantingMonth,
      harvestEstimation: harvestEstimation ?? this.harvestEstimation,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      fertilizerAmount: fertilizerAmount ?? this.fertilizerAmount,
      estimatedIncome: estimatedIncome ?? this.estimatedIncome,
      totalCost: totalCost ?? this.totalCost,
      netProfit: netProfit ?? this.netProfit,
      soilType: soilType ?? this.soilType,
      climateZone: climateZone ?? this.climateZone,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'variety': variety,
      'water_requirement': waterRequirement,
      'best_planting_month': bestPlantingMonth,
      'harvest_estimation': harvestEstimation,
      'fertilizer_type': fertilizerType,
      'fertilizer_amount': fertilizerAmount,
      'estimated_income': estimatedIncome,
      'total_cost': totalCost,
      'net_profit': netProfit,
      'soil_type': soilType,
      'climate_zone': climateZone,
      'recommendations': recommendations,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FarmingInsight.fromMap(Map<String, dynamic> map) {
    return FarmingInsight(
      id: map['id'] as String,
      title: map['title'] as String,
      variety: map['variety'] as String,
      waterRequirement: map['water_requirement'] as String,
      bestPlantingMonth: map['best_planting_month'] as String,
      harvestEstimation: map['harvest_estimation'] as String,
      fertilizerType: map['fertilizer_type'] as String,
      fertilizerAmount: map['fertilizer_amount'] as String,
      estimatedIncome: NumberConverter.fromMap(map, 'estimated_income'),
      totalCost: NumberConverter.fromMap(map, 'total_cost'),
      netProfit: NumberConverter.fromMap(map, 'net_profit'),
      soilType: map['soil_type'] as String,
      climateZone: map['climate_zone'] as String,
      recommendations: map['recommendations'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FarmingInsight.fromJson(String source) =>
      FarmingInsight.fromMap(json.decode(source) as Map<String, dynamic>);
}
