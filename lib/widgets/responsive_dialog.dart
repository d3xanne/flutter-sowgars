import 'package:flutter/material.dart';
import 'package:sample/widgets/standardized_ui.dart';

/// Responsive Dialog Widget that adapts to screen size
class ResponsiveDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;
  final double? maxHeight;

  const ResponsiveDialog({
    Key? key,
    this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    final dialogContent = scrollable
        ? SingleChildScrollView(
            child: content,
          )
        : content;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StandardizedUI.radiusXL),
      ),
      child: Container(
        width: StandardizedUI.dialogWidth(context),
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? (screenHeight * 0.8),
        ),
        padding: EdgeInsets.all(isMobile ? StandardizedUI.spacingM : StandardizedUI.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: StandardizedUI.responsiveFontSize(
                    context,
                    baseSize: 20,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: StandardizedUI.spacingM),
            ],
            Flexible(child: dialogContent),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: StandardizedUI.spacingL),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: StandardizedUI.spacingS,
                runSpacing: StandardizedUI.spacingS,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper function to show responsive dialog
Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  String? title,
  required Widget content,
  List<Widget>? actions,
  bool scrollable = true,
  bool barrierDismissible = true,
  double? maxHeight,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => ResponsiveDialog(
      title: title,
      content: content,
      actions: actions,
      scrollable: scrollable,
      maxHeight: maxHeight,
    ),
  );
}

/// Standardized Alert Dialog
Future<bool?> showStandardAlert({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'OK',
  String? cancelText,
  VoidCallback? onConfirm,
  bool isDestructive = false,
}) {
  return showResponsiveDialog<bool>(
    context: context,
    title: title,
    content: Text(
      message,
      style: const TextStyle(fontSize: 16),
    ),
    actions: [
      if (cancelText != null)
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
          style: StandardizedUI.textButtonStyle(),
        ),
      ElevatedButton(
        onPressed: () {
          if (onConfirm != null) {
            onConfirm();
          }
          Navigator.pop(context, true);
        },
        style: StandardizedUI.elevatedButtonStyle(
          backgroundColor: isDestructive ? Colors.red : null,
        ),
        child: Text(confirmText),
      ),
    ],
  );
}

/// Standardized Confirmation Dialog
Future<bool?> showStandardConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  return showStandardAlert(
    context: context,
    title: title,
    message: message,
    confirmText: confirmText,
    cancelText: cancelText,
    isDestructive: isDestructive,
  );
}

