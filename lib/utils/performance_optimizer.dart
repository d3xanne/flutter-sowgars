import 'package:flutter/material.dart';
import 'dart:async';

/// Performance optimization utilities for the farm management system
class PerformanceOptimizer {
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, dynamic> _cache = {};
  
  /// Debounce function to prevent excessive function calls
  static void debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  /// Memoization for expensive calculations
  static T memoize<T>(String key, T Function() computation) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    final result = computation();
    _cache[key] = result;
    return result;
  }

  /// Clear specific cache entry
  static void clearCacheEntry(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  static void clearCache() {
    _cache.clear();
  }

  /// Cancel all debounce timers
  static void cancelAllTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Dispose all resources
  static void dispose() {
    cancelAllTimers();
    clearCache();
  }
}

/// Optimized widget that prevents unnecessary rebuilds
class OptimizedWidget extends StatelessWidget {
  final Widget child;
  final String? cacheKey;
  final bool shouldCache;
  
  const OptimizedWidget({
    Key? key,
    required this.child,
    this.cacheKey,
    this.shouldCache = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldCache && cacheKey != null) {
      return PerformanceOptimizer.memoize(
        cacheKey!,
        () => child,
      );
    }
    return child;
  }
}

/// Safe async builder that handles loading states and errors
class SafeAsyncBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  final T? initialData;
  
  const SafeAsyncBuilder({
    Key? key,
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.initialData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? 
                 const Center(
                   child: CircularProgressIndicator(
                     color: Color(0xFF2E7D32),
                   ),
                 );
        }
        
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
                 Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(
                         Icons.error_outline,
                         size: 48,
                         color: Colors.red,
                       ),
                       const SizedBox(height: 16),
                       Text(
                         'Error: ${snapshot.error}',
                         textAlign: TextAlign.center,
                         style: const TextStyle(color: Colors.red),
                       ),
                       const SizedBox(height: 16),
                       ElevatedButton(
                         onPressed: () {
                           // Retry logic - rebuild the widget
                         },
                         child: const Text('Retry'),
                       ),
                     ],
                   ),
                 );
        }
        
        if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}

/// Throttled widget to limit rebuild frequency
class ThrottledWidget extends StatefulWidget {
  final Widget child;
  final Duration throttleDuration;
  final String throttleKey;
  
  const ThrottledWidget({
    Key? key,
    required this.child,
    this.throttleDuration = const Duration(milliseconds: 100),
    required this.throttleKey,
  }) : super(key: key);

  @override
  State<ThrottledWidget> createState() => _ThrottledWidgetState();
}

class _ThrottledWidgetState extends State<ThrottledWidget> {
  Timer? _throttleTimer;
  bool _shouldRebuild = true;

  @override
  void didUpdateWidget(ThrottledWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _throttleRebuild();
    }
  }

  void _throttleRebuild() {
    if (_throttleTimer?.isActive ?? false) {
      _shouldRebuild = false;
      return;
    }
    
    _shouldRebuild = true;
    _throttleTimer = Timer(widget.throttleDuration, () {
      if (mounted && _shouldRebuild) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}