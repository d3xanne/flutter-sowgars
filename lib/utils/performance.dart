import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceOptimizer {
  // Optimize frame rate
  static void optimizeFrameRate() {
    SchedulerBinding.instance.platformDispatcher.onBeginFrame = null;
    SchedulerBinding.instance.platformDispatcher.onDrawFrame = null;

    // Set target frame rate (60fps is standard)
    timeDilation = 1.0;
  }

  // Optimize image loading
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}
