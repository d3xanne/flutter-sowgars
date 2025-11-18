import 'package:flutter/material.dart';
import 'package:sample/utils/animations.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final bool enableHover;
  final bool enableScale;
  final bool enableFloating;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHover = true,
    this.enableScale = true,
    this.enableFloating = false,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableScale) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableScale) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableScale) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: _elevationAnimation.value,
      margin: widget.margin,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      color: widget.backgroundColor,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(16),
        child: widget.child,
      ),
    );

    if (widget.enableFloating) {
      card = AppAnimations.floatingAnimation(
        child: card,
        duration: const Duration(seconds: 3),
      );
    }

    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: card,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: card,
    );
  }
}

// Specialized card for dashboard metrics
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool showTrend;
  final double? trendValue;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.showTrend = false,
    this.trendValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      enableFloating: true,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              if (showTrend && trendValue != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendValue! >= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendValue! >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: trendValue! >= 0 ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trendValue!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: trendValue! >= 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Action card with enhanced animations
class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? description;

  const ActionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      enableScale: true,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
