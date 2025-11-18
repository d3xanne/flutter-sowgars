import 'package:flutter_test/flutter_test.dart';
import 'package:sample/services/insight_generator_service.dart';

void main() {
  group('InsightGeneratorService', () {
    test('should get available varieties', () {
      final varieties = InsightGeneratorService.getAvailableVarieties();
      
      expect(varieties, isNotEmpty);
      expect(varieties, contains('Phil 2009'));
    });

    test('should get available climate zones', () {
      final zones = InsightGeneratorService.getAvailableClimateZones();
      
      expect(zones, isNotEmpty);
    });

    test('should get available soil types', () {
      final soilTypes = InsightGeneratorService.getAvailableSoilTypes();
      
      expect(soilTypes, isNotEmpty);
    });

    test('should get variety details', () {
      final details = InsightGeneratorService.getVarietyDetails('Phil 2009');
      
      expect(details, isNotNull);
      expect(details!['yield_per_hectare'], isNotNull);
    });
  });
}

