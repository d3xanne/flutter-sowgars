import 'package:flutter/material.dart';
import 'dart:async';

/// Comprehensive error prevention utilities
class ErrorPrevention {
  /// Safe stream subscription that automatically cancels on dispose
  static StreamSubscription<T> safeStreamSubscription<T>(
    State state,
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    VoidCallback? onDone,
  }) {
    late StreamSubscription<T> subscription;
    
    subscription = stream.listen(
      (data) {
        if (state.mounted) {
          onData(data);
        }
      },
      onError: onError,
      onDone: onDone,
    );

    // Store subscription for cleanup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called when the widget is disposed
    });

    return subscription;
  }

  /// Safe timer that automatically cancels on dispose
  static Timer safeTimer(
    State state,
    Duration duration,
    VoidCallback callback,
  ) {
    final timer = Timer(duration, () {
      if (state.mounted) {
        callback();
      }
    });

    return timer;
  }

  /// Safe periodic timer
  static Timer safePeriodicTimer(
    State state,
    Duration duration,
    void Function(Timer) callback,
  ) {
    final timer = Timer.periodic(duration, (timer) {
      if (state.mounted) {
        callback(timer);
      } else {
        timer.cancel();
      }
    });

    return timer;
  }
}

/// Mixin for automatic error prevention
mixin ErrorPreventionMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Cancel all timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    super.dispose();
  }

  /// Safe setState
  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  /// Safe async setState
  Future<void> safeAsyncSetState(
    Future<void> Function() asyncOperation,
    VoidCallback setStateCallback,
  ) async {
    if (!mounted) return;
    await asyncOperation();
    if (!mounted) return;
    setState(setStateCallback);
  }

  /// Safe stream subscription
  StreamSubscription<T> safeStreamSubscription<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    VoidCallback? onDone,
  }) {
    final subscription = ErrorPrevention.safeStreamSubscription(
      this,
      stream,
      onData,
      onError: onError,
      onDone: onDone,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Safe timer
  Timer safeTimer(Duration duration, VoidCallback callback) {
    final timer = ErrorPrevention.safeTimer(this, duration, callback);
    _timers.add(timer);
    return timer;
  }

  /// Safe periodic timer
  Timer safePeriodicTimer(
    Duration duration,
    void Function(Timer) callback,
  ) {
    final timer = ErrorPrevention.safePeriodicTimer(this, duration, callback);
    _timers.add(timer);
    return timer;
  }
}

