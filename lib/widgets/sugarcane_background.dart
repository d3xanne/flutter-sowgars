import 'package:flutter/material.dart';

/// A reusable sugarcane farming background widget
/// Adds a subtle background image with overlay to all features
class SugarcaneBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final bool enabled;

  const SugarcaneBackground({
    Key? key,
    required this.child,
    this.opacity = 0.15,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Stack(
      children: [
        // Background image with overlay
        _buildBackground(context),
        
        // Content
        child,
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          // Try to load the background image
          image: _getBackgroundImage(),
          // Fallback to gradient if image fails
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2E7D32).withValues(alpha: 0.08),
              const Color(0xFF4CAF50).withValues(alpha: 0.05),
              const Color(0xFF2E7D32).withValues(alpha: 0.1),
            ],
          ),
        ),
        // Dark overlay to ensure content readability
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.92 - opacity),
                Colors.white.withValues(alpha: 0.95 - opacity),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _getBackgroundImage() {
    // Correct filename without double .jpg
    final imagePath = 'assets/field_background.jpg';
    
    try {
      // Use AssetImage to load from assets
      return DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: opacity),
          BlendMode.darken,
        ),
      );
    } catch (e) {
      // If image doesn't exist, return null to use gradient fallback
      return null;
    }
  }
}

/// Alternative: Pure gradient sugarcane background (no image needed)
class SugarcaneGradientBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const SugarcaneGradientBackground({
    Key? key,
    required this.child,
    this.opacity = 0.12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // Light green tones (sugarcane colors)
            const Color(0xFF2E7D32).withValues(alpha: opacity),
            const Color(0xFF4CAF50).withValues(alpha: opacity * 0.7),
            const Color(0xFF66BB6A).withValues(alpha: opacity * 0.5),
            const Color(0xFF2E7D32).withValues(alpha: opacity),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

