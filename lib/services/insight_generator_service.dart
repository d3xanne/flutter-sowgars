import 'package:sample/models/farming_insight.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/utils/number_converter.dart';

class InsightGeneratorService {
  // Sugarcane varieties with their characteristics
  static const Map<String, Map<String, dynamic>> _sugarcaneVarieties = {
    'Phil 2009': {
      'yield_per_hectare': 80.0, // tons
      'maturity_period': 12, // months
      'water_requirement': 'High',
      'fertilizer_requirement': 'NPK 15-15-15',
      'fertilizer_amount_per_hectare': 300.0, // kg
      'disease_resistance': 'High',
      'sugar_content': 12.5, // %
      'price_per_ton': 2500.0, // PHP
    },
    'Phil 2012': {
      'yield_per_hectare': 75.0,
      'maturity_period': 11,
      'water_requirement': 'Medium',
      'fertilizer_requirement': 'NPK 20-10-10',
      'fertilizer_amount_per_hectare': 280.0,
      'disease_resistance': 'Medium',
      'sugar_content': 13.0,
      'price_per_ton': 2600.0,
    },
    'Phil 2015': {
      'yield_per_hectare': 85.0,
      'maturity_period': 13,
      'water_requirement': 'High',
      'fertilizer_requirement': 'NPK 18-18-18',
      'fertilizer_amount_per_hectare': 320.0,
      'disease_resistance': 'High',
      'sugar_content': 13.5,
      'price_per_ton': 2700.0,
    },
    'Phil 2018': {
      'yield_per_hectare': 90.0,
      'maturity_period': 12,
      'water_requirement': 'High',
      'fertilizer_requirement': 'NPK 16-16-16',
      'fertilizer_amount_per_hectare': 300.0,
      'disease_resistance': 'Very High',
      'sugar_content': 14.0,
      'price_per_ton': 2800.0,
    },
    'Phil 2021': {
      'yield_per_hectare': 95.0,
      'maturity_period': 11,
      'water_requirement': 'Medium',
      'fertilizer_requirement': 'NPK 14-14-14',
      'fertilizer_amount_per_hectare': 290.0,
      'disease_resistance': 'High',
      'sugar_content': 14.5,
      'price_per_ton': 2900.0,
    },
  };

  // Climate zones and their characteristics
  static const Map<String, Map<String, dynamic>> _climateZones = {
    'Tropical Wet': {
      'rainfall': 'High (2000-4000mm)',
      'temperature': '25-30°C',
      'humidity': 'High (80-90%)',
      'best_planting_months': ['March', 'April', 'May'],
      'water_requirement_adjustment': 0.8,
    },
    'Tropical Dry': {
      'rainfall': 'Low (500-1500mm)',
      'temperature': '28-35°C',
      'humidity': 'Medium (60-80%)',
      'best_planting_months': ['June', 'July', 'August'],
      'water_requirement_adjustment': 1.2,
    },
    'Subtropical': {
      'rainfall': 'Medium (1000-2000mm)',
      'temperature': '20-28°C',
      'humidity': 'Medium (70-85%)',
      'best_planting_months': ['September', 'October', 'November'],
      'water_requirement_adjustment': 1.0,
    },
  };

  // Soil types and their characteristics
  static const Map<String, Map<String, dynamic>> _soilTypes = {
    'Clay': {
      'water_retention': 'High',
      'drainage': 'Poor',
      'fertility': 'High',
      'ph_range': '6.0-7.5',
      'fertilizer_efficiency': 1.1,
    },
    'Sandy': {
      'water_retention': 'Low',
      'drainage': 'Excellent',
      'fertility': 'Low',
      'ph_range': '5.5-6.5',
      'fertilizer_efficiency': 0.9,
    },
    'Loam': {
      'water_retention': 'Medium',
      'drainage': 'Good',
      'fertility': 'High',
      'ph_range': '6.0-7.0',
      'fertilizer_efficiency': 1.0,
    },
    'Silt': {
      'water_retention': 'High',
      'drainage': 'Medium',
      'fertility': 'High',
      'ph_range': '6.5-7.5',
      'fertilizer_efficiency': 1.05,
    },
  };

  static Future<FarmingInsight> generateInsight({
    required String soilType,
    required String climateZone,
    required double farmSize, // in hectares
    required List<SugarRecord> historicalRecords,
    required List<InventoryItem> inventoryItems,
    required List<SupplierTransaction> supplierTransactions,
  }) async {
    // Analyze historical data to determine best variety
    final bestVariety = _analyzeBestVariety(historicalRecords);
    final varietyData = _sugarcaneVarieties[bestVariety]!;
    final climateData = _climateZones[climateZone]!;
    final soilData = _soilTypes[soilType]!;

    // Calculate water requirements
    final baseWaterRequirement = varietyData['water_requirement'] as String;
    final climateAdjustment = climateData['water_requirement_adjustment'] as double;
    final waterRequirement = _calculateWaterRequirement(
      baseWaterRequirement,
      climateAdjustment,
      farmSize,
    );

    // Determine best planting month
    final bestPlantingMonth = _determineBestPlantingMonth(climateZone);

    // Calculate harvest estimation
    final harvestEstimation = _calculateHarvestEstimation(
      varietyData,
      farmSize,
      soilData,
    );

    // Determine fertilizer requirements
    final fertilizerType = varietyData['fertilizer_requirement'] as String;
    final fertilizerAmount = _calculateFertilizerAmount(
      varietyData,
      farmSize,
      soilData,
    );

    // Calculate costs and income
    final costs = _calculateCosts(
      farmSize,
      varietyData,
      fertilizerAmount,
      supplierTransactions,
    );

    final income = _calculateIncome(
      varietyData,
      farmSize,
      harvestEstimation,
    );

    final netProfit = income - (costs['total'] ?? 0.0);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      bestVariety,
      varietyData,
      climateData,
      soilData,
      waterRequirement,
      fertilizerType,
      fertilizerAmount,
    );

    return FarmingInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Farming Insight for ${bestVariety} - ${farmSize} hectares',
      variety: bestVariety,
      waterRequirement: waterRequirement,
      bestPlantingMonth: bestPlantingMonth,
      harvestEstimation: harvestEstimation,
      fertilizerType: fertilizerType,
      fertilizerAmount: fertilizerAmount,
      estimatedIncome: income,
      totalCost: costs['total'] ?? 0.0,
      netProfit: NumberConverter.toDouble(netProfit),
      soilType: soilType,
      climateZone: climateZone,
      recommendations: recommendations,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  static String _analyzeBestVariety(List<SugarRecord> records) {
    if (records.isEmpty) {
      // Return a default variety if no historical data
      return 'Phil 2018';
    }

    // Analyze performance by variety
    final Map<String, List<int>> varietyHeights = {};
    for (final record in records) {
      varietyHeights.putIfAbsent(record.variety, () => []).add(record.heightCm);
    }

    // Calculate average height for each variety
    final Map<String, double> varietyAverages = {};
    varietyHeights.forEach((variety, heights) {
      varietyAverages[variety] = heights.reduce((a, b) => a + b) / heights.length;
    });

    // Find the variety with highest average height
    String bestVariety = varietyAverages.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // If the best variety is not in our database, use a default
    if (!_sugarcaneVarieties.containsKey(bestVariety)) {
      bestVariety = 'Phil 2018';
    }

    return bestVariety;
  }

  static String _calculateWaterRequirement(
    String baseRequirement,
    double climateAdjustment,
    double farmSize,
  ) {
    double baseAmount;
    switch (baseRequirement) {
      case 'High':
        baseAmount = 1500.0; // liters per hectare per day
        break;
      case 'Medium':
        baseAmount = 1200.0;
        break;
      case 'Low':
        baseAmount = 900.0;
        break;
      default:
        baseAmount = 1200.0;
    }

    final adjustedAmount = baseAmount * climateAdjustment;
    final totalAmount = adjustedAmount * farmSize;

    return '${totalAmount.toStringAsFixed(0)} liters per day (${(totalAmount * 30).toStringAsFixed(0)} liters per month)';
  }

  static String _determineBestPlantingMonth(String climateZone) {
    final climateData = _climateZones[climateZone];
    if (climateData != null) {
      final months = climateData['best_planting_months'] as List<String>;
      return months.join(', ');
    }
    return 'March, April, May';
  }

  static String _calculateHarvestEstimation(
    Map<String, dynamic> varietyData,
    double farmSize,
    Map<String, dynamic> soilData,
  ) {
    final yieldPerHectare = varietyData['yield_per_hectare'] as double;
    final maturityPeriod = varietyData['maturity_period'] as int;
    final fertilizerEfficiency = soilData['fertilizer_efficiency'] as double;

    final estimatedYield = yieldPerHectare * farmSize * fertilizerEfficiency;
    final harvestDate = DateTime.now().add(Duration(days: maturityPeriod * 30));

    return '${estimatedYield.toStringAsFixed(1)} tons in ${maturityPeriod} months (${harvestDate.day}/${harvestDate.month}/${harvestDate.year})';
  }

  static String _calculateFertilizerAmount(
    Map<String, dynamic> varietyData,
    double farmSize,
    Map<String, dynamic> soilData,
  ) {
    final baseAmount = varietyData['fertilizer_amount_per_hectare'] as double;
    final fertilizerEfficiency = soilData['fertilizer_efficiency'] as double;
    final totalAmount = baseAmount * farmSize * fertilizerEfficiency;

    return '${totalAmount.toStringAsFixed(0)} kg (${(totalAmount / 50).toStringAsFixed(1)} bags)';
  }

  static Map<String, double> _calculateCosts(
    double farmSize,
    Map<String, dynamic> varietyData,
    String fertilizerAmount,
    List<SupplierTransaction> supplierTransactions,
  ) {
    // Calculate fertilizer cost
    final fertilizerKg = double.parse(fertilizerAmount.split(' ')[0]);
    final fertilizerCostPerKg = _getFertilizerCostPerKg(supplierTransactions);
    final fertilizerCost = fertilizerKg * fertilizerCostPerKg;

    // Calculate seed cost (assuming 2 tons per hectare)
    final seedTons = farmSize * 2.0;
    final seedCostPerTon = 1500.0; // PHP per ton
    final seedCost = seedTons * seedCostPerTon;

    // Calculate labor cost (assuming 10 workers per hectare)
    final laborCostPerHectare = 5000.0; // PHP per hectare
    final laborCost = farmSize * laborCostPerHectare;

    // Calculate equipment cost
    final equipmentCost = farmSize * 2000.0; // PHP per hectare

    // Calculate irrigation cost
    final irrigationCost = farmSize * 1500.0; // PHP per hectare

    // Calculate other costs (pesticides, etc.)
    final otherCosts = farmSize * 1000.0; // PHP per hectare

    final total = fertilizerCost + seedCost + laborCost + equipmentCost + irrigationCost + otherCosts;

    return {
      'fertilizer': fertilizerCost,
      'seeds': seedCost,
      'labor': laborCost,
      'equipment': equipmentCost,
      'irrigation': irrigationCost,
      'other': otherCosts,
      'total': total,
    };
  }

  static double _getFertilizerCostPerKg(List<SupplierTransaction> transactions) {
    // Find recent fertilizer transactions
    final fertilizerTransactions = transactions
        .where((t) => t.itemName.toLowerCase().contains('fertilizer'))
        .toList();

    if (fertilizerTransactions.isEmpty) {
      return 45.0; // Default cost per kg
    }

    // Calculate average cost per kg
    double totalCost = 0;
    double totalKg = 0;

    for (final transaction in fertilizerTransactions) {
      totalCost += transaction.amount;
      // Assume each bag is 50kg
      totalKg += transaction.quantity * 50;
    }

    return totalKg > 0 ? totalCost / totalKg : 45.0;
  }

  static double _calculateIncome(
    Map<String, dynamic> varietyData,
    double farmSize,
    String harvestEstimation,
  ) {
    final yieldPerHectare = varietyData['yield_per_hectare'] as double;
    final pricePerTon = varietyData['price_per_ton'] as double;
    final estimatedYield = yieldPerHectare * farmSize;

    return estimatedYield * pricePerTon;
  }

  static String _generateRecommendations(
    String variety,
    Map<String, dynamic> varietyData,
    Map<String, dynamic> climateData,
    Map<String, dynamic> soilData,
    String waterRequirement,
    String fertilizerType,
    String fertilizerAmount,
  ) {
    final recommendations = <String>[];

    // Variety-specific recommendations
    recommendations.add('• Plant ${variety} variety for optimal yield (${varietyData['yield_per_hectare']} tons/hectare)');
    recommendations.add('• Expected maturity period: ${varietyData['maturity_period']} months');
    recommendations.add('• Sugar content: ${varietyData['sugar_content']}%');

    // Water management
    recommendations.add('• Water requirement: $waterRequirement');
    recommendations.add('• Install efficient irrigation system for optimal water distribution');

    // Fertilizer recommendations
    recommendations.add('• Use $fertilizerType fertilizer');
    recommendations.add('• Apply $fertilizerAmount for optimal growth');
    recommendations.add('• Split application: 50% at planting, 25% at 3 months, 25% at 6 months');

    // Soil management
    recommendations.add('• Soil type: ${soilData['water_retention']} water retention, ${soilData['drainage']} drainage');
    recommendations.add('• Maintain pH level between ${soilData['ph_range']}');
    recommendations.add('• Regular soil testing recommended every 3 months');

    // Climate considerations
    recommendations.add('• Climate zone: ${climateData['rainfall']} rainfall, ${climateData['temperature']} temperature');
    recommendations.add('• Best planting months: ${climateData['best_planting_months']}');
    recommendations.add('• Monitor weather conditions for optimal planting timing');

    // Disease and pest management
    recommendations.add('• Disease resistance: ${varietyData['disease_resistance']}');
    recommendations.add('• Regular field monitoring for pests and diseases');
    recommendations.add('• Implement integrated pest management (IPM) strategies');

    // Harvest and post-harvest
    recommendations.add('• Plan harvest during dry season for better sugar quality');
    recommendations.add('• Ensure proper storage facilities for harvested cane');
    recommendations.add('• Coordinate with sugar mill for timely delivery');

    return recommendations.join('\n');
  }

  // Get available varieties for selection
  static List<String> getAvailableVarieties() {
    return _sugarcaneVarieties.keys.toList();
  }

  // Get variety details
  static Map<String, dynamic>? getVarietyDetails(String variety) {
    return _sugarcaneVarieties[variety];
  }

  // Get available climate zones
  static List<String> getAvailableClimateZones() {
    return _climateZones.keys.toList();
  }

  // Get available soil types
  static List<String> getAvailableSoilTypes() {
    return _soilTypes.keys.toList();
  }
}
