import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sample/services/consolidated_service.dart';

/// Widget to monitor and display system performance metrics
class PerformanceMonitor extends StatefulWidget {
  final bool showDetails;
  
  const PerformanceMonitor({
    Key? key,
    this.showDetails = false,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  Map<String, dynamic> _healthData = {};
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _updateHealthData();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateHealthData(),
    );
  }

  void _updateHealthData() {
    if (mounted) {
      setState(() {
        _healthData = ConsolidatedService.getSystemHealth();
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showDetails) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'System Performance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Subscriptions: ${_healthData['active_subscriptions'] ?? 0}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Timers: ${_healthData['active_timers'] ?? 0}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Cached Items: ${_healthData['cached_items'] ?? 0}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Mixin to add performance monitoring to any widget
mixin PerformanceMonitoringMixin<T extends StatefulWidget> on State<T> {
  int _buildCount = 0;
  
  @override
  Widget build(BuildContext context) {
    _buildCount++;
    
    // Log excessive rebuilds
    if (_buildCount > 10) {
      print('⚠️ Widget ${T.toString()} has rebuilt $_buildCount times');
    }
    
    return super.build(context);
  }
  
  void resetBuildCount() {
    _buildCount = 0;
  }
  
  int get buildCount => _buildCount;
}
