import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/farming_insight.dart';

void main() {
  group('FarmingInsight', () {
    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'title': 'Test Insight',
        'variety': 'Phil 2009',
        'water_requirement': 'High',
        'best_planting_month': 'January',
        'harvest_estimation': '12 months',
        'fertilizer_type': 'NPK',
        'fertilizer_amount': '100kg',
        'estimated_income': 50000.0,
        'total_cost': 30000.0,
        'net_profit': 20000.0,
        'soil_type': 'Loam',
        'climate_zone': 'Tropical',
        'recommendations': 'Test recommendations',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
      };

      final insight = FarmingInsight.fromMap(map);

      expect(insight.id, equals('test-id'));
      expect(insight.title, equals('Test Insight'));
      expect(insight.variety, equals('Phil 2009'));
      expect(insight.estimatedIncome, equals(50000.0));
      expect(insight.totalCost, equals(30000.0));
      expect(insight.netProfit, equals(20000.0));
    });

    test('should convert to map correctly', () {
      final insight = FarmingInsight(
        id: 'test-id',
        title: 'Test Insight',
        variety: 'Phil 2009',
        waterRequirement: 'High',
        bestPlantingMonth: 'January',
        harvestEstimation: '12 months',
        fertilizerType: 'NPK',
        fertilizerAmount: '100kg',
        estimatedIncome: 50000.0,
        totalCost: 30000.0,
        netProfit: 20000.0,
        soilType: 'Loam',
        climateZone: 'Tropical',
        recommendations: 'Test recommendations',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final map = insight.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['title'], equals('Test Insight'));
      expect(map['estimated_income'], equals(50000.0));
    });
  });
}

