import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: color ?? Colors.white,
        size: size ?? 20,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      tooltip: tooltip ?? 'Go Back',
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class BackButtonWithText extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Color? color;
  final double? iconSize;
  final double? fontSize;

  const BackButtonWithText({
    super.key,
    this.onPressed,
    this.text,
    this.color,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios,
              color: color ?? Colors.white,
              size: iconSize ?? 16,
            ),
            const SizedBox(width: 4),
            Text(
              text ?? 'Back',
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: fontSize ?? 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackButtonCard extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const BackButtonCard({
    super.key,
    this.onPressed,
    required this.title,
    this.subtitle,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon ?? Icons.arrow_back_ios,
                color: textColor ?? Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: (textColor ?? Colors.white).withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
