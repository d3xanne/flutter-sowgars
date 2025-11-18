import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeatherBackground extends StatefulWidget {
  final String weatherCondition;
  final Widget child;

  const WeatherBackground({
    Key? key,
    required this.weatherCondition,
    required this.child,
  }) : super(key: key);

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
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
    return Container(
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(),
      ),
      child: Stack(
        children: [
          _buildAnimatedBackground(),
          widget.child,
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient() {
    switch (widget.weatherCondition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF87CEEB), // Sky blue
            Color(0xFF98D8E8), // Light blue
            Color(0xFFB0E0E6), // Powder blue
          ],
        );
      case 'clouds':
      case 'cloudy':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF708090), // Slate gray
            Color(0xFF778899), // Light slate gray
            Color(0xFFB0C4DE), // Light steel blue
          ],
        );
      case 'rain':
      case 'rainy':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4682B4), // Steel blue
            Color(0xFF5F9EA0), // Cadet blue
            Color(0xFF87CEEB), // Sky blue
          ],
        );
      case 'thunderstorm':
      case 'storm':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F4F4F), // Dark slate gray
            Color(0xFF4682B4), // Steel blue
            Color(0xFF708090), // Slate gray
          ],
        );
      case 'snow':
      case 'snowy':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F8FF), // Alice blue
            Color(0xFFE6E6FA), // Lavender
            Color(0xFFB0C4DE), // Light steel blue
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        );
    }
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: WeatherParticlesPainter(
            animation: _animation.value,
            weatherCondition: widget.weatherCondition,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class WeatherParticlesPainter extends CustomPainter {
  final double animation;
  final String weatherCondition;

  WeatherParticlesPainter({
    required this.animation,
    required this.weatherCondition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.1);

    switch (weatherCondition.toLowerCase()) {
      case 'rain':
      case 'rainy':
        _drawRain(canvas, size, paint);
        break;
      case 'snow':
      case 'snowy':
        _drawSnow(canvas, size, paint);
        break;
      case 'clear':
      case 'sunny':
        _drawSunRays(canvas, size, paint);
        break;
      case 'clouds':
      case 'cloudy':
        _drawClouds(canvas, size, paint);
        break;
    }
  }

  void _drawRain(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0) % size.width;
      final y = (animation * size.height + i * 10) % size.height;
      
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 20),
        paint..strokeWidth = 1,
      );
    }
  }

  void _drawSnow(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < 30; i++) {
      final x = (i * 47.0) % size.width;
      final y = (animation * size.height + i * 15) % size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        2,
        paint,
      );
    }
  }

  void _drawSunRays(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width * 0.8, size.height * 0.2);
    final radius = 30.0;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0 + animation * 360) * (3.14159 / 180);
      final startX = center.dx + radius * 1.5 * math.cos(angle);
      final startY = center.dy + radius * 1.5 * math.sin(angle);
      final endX = center.dx + radius * 2.5 * math.cos(angle);
      final endY = center.dy + radius * 2.5 * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = 2,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < 5; i++) {
      final x = (i * 200.0 + animation * 100) % (size.width + 100);
      final y = size.height * 0.2 + i * 50;
      
      _drawCloud(canvas, Offset(x, y), paint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: 20));
    path.addOval(Rect.fromCircle(center: Offset(center.dx - 15, center.dy), radius: 25));
    path.addOval(Rect.fromCircle(center: Offset(center.dx + 15, center.dy), radius: 25));
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy - 10), radius: 20));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WeatherParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.weatherCondition != weatherCondition;
  }
}
