import 'package:flutter/material.dart';
import 'package:sample/widgets/standardized_ui.dart';

/// Loading Overlay Widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(StandardizedUI.spacingL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(StandardizedUI.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StandardizedUI.loadingIndicator(
                      size: 40,
                      message: message,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Show loading dialog
void showLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(StandardizedUI.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(StandardizedUI.radiusL),
          ),
          child: StandardizedUI.loadingIndicator(message: message),
        ),
      ),
    ),
  );
}

/// Hide loading dialog
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

