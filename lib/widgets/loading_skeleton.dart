import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.1),
                  Colors.grey.withValues(alpha: 0.3),
                ],
                stops: [
                  0.0,
                  0.5,
                  1.0,
                ],
                transform: GradientRotation(_animation.value * 2 * 3.14159),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LoadingSkeleton(width: 48, height: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LoadingSkeleton(width: 120, height: 16),
                    const SizedBox(height: 8),
                    const LoadingSkeleton(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LoadingSkeleton(width: double.infinity, height: 20),
          const SizedBox(height: 8),
          const LoadingSkeleton(width: 200, height: 16),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const CardSkeleton(),
    );
  }
}