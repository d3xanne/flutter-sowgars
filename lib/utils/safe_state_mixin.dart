import 'package:flutter/material.dart';

/// Mixin to provide safe setState functionality
/// Prevents setState after dispose errors
mixin SafeStateMixin<T extends StatefulWidget> on State<T> {
  /// Safely calls setState only if the widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Safely calls setState with a return value
  R? safeSetStateWithReturn<R>(R Function() fn) {
    if (mounted) {
      setState(fn);
      return fn();
    }
    return null;
  }

  /// Safely executes an async operation and calls setState
  Future<void> safeAsyncSetState(Future<void> Function() operation) async {
    if (mounted) {
      await operation();
    }
  }

  /// Safely executes an async operation with setState callback
  Future<void> safeAsyncSetStateWithCallback(
    Future<void> Function() operation,
    VoidCallback setStateCallback,
  ) async {
    if (mounted) {
      await operation();
      if (mounted) {
        setState(setStateCallback);
      }
    }
  }
}

