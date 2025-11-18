import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/models/farming_insight.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/services/insight_generator_service.dart';
import 'package:sample/services/local_repository.dart';

class GenerateInsightScreen extends StatefulWidget {
  const GenerateInsightScreen({Key? key}) : super(key: key);

  @override
  State<GenerateInsightScreen> createState() => _GenerateInsightScreenState();
}

class _GenerateInsightScreenState extends State<GenerateInsightScreen>
    with TickerProviderStateMixin {
  final LocalRepository _repo = LocalRepository.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _farmSizeController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _climateZoneController = TextEditingController();

  // Form state
  String _selectedSoilType = 'Loam';
  String _selectedClimateZone = 'Tropical Wet';
  double _farmSize = 1.0;
  bool _isGenerating = false;
  FarmingInsight? _generatedInsight;

  // Data
  List<SugarRecord> _sugarRecords = [];
  List<InventoryItem> _inventoryItems = [];
  List<SupplierTransaction> _supplierTransactions = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _farmSizeController.dispose();
    _soilTypeController.dispose();
    _climateZoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final sugarRecords = await _repo.getSugarRecords();
      final inventoryItems = await _repo.getInventoryItems();
      final supplierTransactions = await _repo.getSupplierTransactions();

      if (mounted) {
        setState(() {
          _sugarRecords = sugarRecords;
          _inventoryItems = inventoryItems;
          _supplierTransactions = supplierTransactions;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _generateInsight() async {
    if (_farmSize <= 0) {
      _showErrorSnackBar('Please enter a valid farm size');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final insight = await InsightGeneratorService.generateInsight(
        soilType: _selectedSoilType,
        climateZone: _selectedClimateZone,
        farmSize: _farmSize,
        historicalRecords: _sugarRecords,
        inventoryItems: _inventoryItems,
        supplierTransactions: _supplierTransactions,
      );

      if (mounted) {
        setState(() {
          _generatedInsight = insight;
          _isGenerating = false;
        });

        // Save the insight to local repository with error handling
        try {
          await _repo.addFarmingInsight(insight);
          _showSuccessSnackBar('Insight generated and saved successfully!');
        } catch (saveError) {
          print('⚠️ Error saving insight: $saveError');
          _showSuccessSnackBar('Insight generated successfully! (Save failed)');
        }
      }
    } catch (e) {
      print('❌ Error generating insight: $e');
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _showErrorSnackBar('Error generating insight: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildForm(),
                    const SizedBox(height: 30),
                    if (_generatedInsight != null) _buildInsightResults(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate Farming Insight',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Get personalized recommendations for your sugarcane farm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Configuration',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildFarmSizeInput(),
          const SizedBox(height: 20),
          _buildSoilTypeSelector(),
          const SizedBox(height: 20),
          _buildClimateZoneSelector(),
          const SizedBox(height: 30),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildFarmSizeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Size (Hectares)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _farmSizeController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter farm size in hectares',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _farmSize = double.tryParse(value) ?? 1.0;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSoilTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Soil Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedSoilType,
          dropdownColor: const Color(0xFF2D3748),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
          items: InsightGeneratorService.getAvailableSoilTypes().map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSoilType = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildClimateZoneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Climate Zone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedClimateZone,
          dropdownColor: const Color(0xFF2D3748),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
          items: InsightGeneratorService.getAvailableClimateZones().map((String zone) {
            return DropdownMenuItem<String>(
              value: zone,
              child: Text(zone),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClimateZone = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateInsight,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Generating Insight...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Generate Insight',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInsightResults() {
    if (_generatedInsight == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Color(0xFF4CAF50), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Farming Insight Results',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightCard('Variety Recommendation', _generatedInsight!.variety, Icons.eco),
          _buildInsightCard('Water Requirement', _generatedInsight!.waterRequirement, Icons.water_drop),
          _buildInsightCard('Best Planting Month', _generatedInsight!.bestPlantingMonth, Icons.calendar_today),
          _buildInsightCard('Harvest Estimation', _generatedInsight!.harvestEstimation, Icons.grass),
          _buildInsightCard('Fertilizer Type', _generatedInsight!.fertilizerType, Icons.agriculture),
          _buildInsightCard('Fertilizer Amount', _generatedInsight!.fertilizerAmount, Icons.scale),
          const SizedBox(height: 20),
          _buildFinancialSummary(),
          const SizedBox(height: 20),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Income:', style: TextStyle(color: Colors.white)),
              Text(
                '₱${_generatedInsight!.estimatedIncome.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Cost:', style: TextStyle(color: Colors.white)),
              Text(
                '₱${_generatedInsight!.totalCost.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Net Profit:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '₱${_generatedInsight!.netProfit.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _generatedInsight!.recommendations,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
