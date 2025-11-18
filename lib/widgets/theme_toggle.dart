import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;
  
  const ThemeToggle({
    Key? key,
    this.showLabel = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simple theme toggle that works with system theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (isCompact) {
      return IconButton(
        icon: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: AppTheme.getTextColor(context),
        ),
        onPressed: () {
          // Show a message about theme switching
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel)
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSimpleThemeButton(
                  context,
                  ThemeMode.light,
                  Icons.light_mode,
                  'Light',
                  isDarkMode,
                ),
                const SizedBox(width: 4),
                _buildSimpleThemeButton(
                  context,
                  ThemeMode.dark,
                  Icons.dark_mode,
                  'Dark',
                  isDarkMode,
                ),
                const SizedBox(width: 4),
                _buildSimpleThemeButton(
                  context,
                  ThemeMode.system,
                  Icons.settings_suggest,
                  'Auto',
                  isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleThemeButton(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String label,
    bool isDarkMode,
  ) {
    final isSelected = (mode == ThemeMode.system) || 
                      (mode == ThemeMode.light && !isDarkMode) ||
                      (mode == ThemeMode.dark && isDarkMode);
    
    return GestureDetector(
      onTap: () {
        // Show a message about theme switching
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme switching: $label'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.getPrimaryColor(context).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getTextSecondaryColor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? AppTheme.getPrimaryColor(context)
                  : AppTheme.getTextColor(context),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? AppTheme.getPrimaryColor(context)
                    : AppTheme.getTextColor(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

