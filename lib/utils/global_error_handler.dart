import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GlobalErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        // In production, log to crash reporting service
        _logError(details.exception, details.stack);
      }
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  static void _logError(dynamic error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
    }
    // In production, send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }

  static Widget buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Restart app or navigate to safe state
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// Safe setState wrapper
mixin SafeStateMixin<T extends StatefulWidget> on State<T> {
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

// Safe async operation wrapper
class SafeAsync {
  static Future<T?> execute<T>(
    Future<T> Function() operation, {
    T? fallback,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      if (onError != null) {
        onError(error);
      } else if (kDebugMode) {
        debugPrint('SafeAsync Error: $error');
      }
      return fallback;
    }
  }
}
