// CREATE THIS NEW FILE: lib/utils/error_handler.dart
import 'package:flutter/material.dart';
import 'package:sample/widgets/standardized_ui.dart';
import 'package:sample/widgets/responsive_dialog.dart';

class ErrorHandler {
  // Show a snackbar with an error message
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StandardizedUI.radiusM),
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show a dialog with an error message
  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showStandardAlert(
      context: context,
      title: title,
      message: message,
      confirmText: 'OK',
    );
  }

  // Show a retry dialog
  static Future<bool> showRetryDialog(
      BuildContext context, String message) async {
    return await showStandardConfirmation(
      context: context,
      title: 'Error',
      message: message,
      confirmText: 'Retry',
      cancelText: 'Cancel',
    ) ?? false;
  }

  // Handle network errors
  static Future<void> handleNetworkError(
    BuildContext context,
    Exception error,
    Function retryCallback,
  ) async {
    final shouldRetry = await showRetryDialog(
      context,
      'Network error occurred. Please check your connection and try again.',
    );

    if (shouldRetry) {
      await retryCallback();
    }
  }
}
