import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sample/screens/professional_navigation.dart';

class ProfessionalSplashScreen extends StatefulWidget {
  const ProfessionalSplashScreen({super.key});

  @override
  State<ProfessionalSplashScreen> createState() => _ProfessionalSplashScreenState();
}

class _ProfessionalSplashScreenState extends State<ProfessionalSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _loadingController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.6)),
    );
    
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 1.0)),
    );
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );
    
    _loadingOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _backgroundController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    
    // Fade out loading indicator 500ms before navigation
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      _loadingController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ProfessionalNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0E27).withValues(alpha: _backgroundOpacity.value),
                  const Color(0xFF1A1F3A).withValues(alpha: _backgroundOpacity.value),
                  const Color(0xFF2D3748).withValues(alpha: _backgroundOpacity.value),
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildBackgroundPattern(),
                _buildContent(),
                _buildLoadingIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      painter: BackgroundPatternPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenHeight < 700;
        final isMobile = screenWidth < 600;
        
        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
                maxWidth: 1200, // Limit max width for better centering on large screens
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isSmallScreen ? 20 : 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  _buildLogo(isSmallScreen, isMobile),
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  _buildTitle(isSmallScreen, isMobile),
                  SizedBox(height: isSmallScreen ? 12 : 20),
                  _buildSubtitle(isSmallScreen, isMobile),
                  SizedBox(height: isSmallScreen ? 30 : 60),
                  _buildFeatures(isSmallScreen, isMobile),
                  SizedBox(height: isSmallScreen ? 20 : 40),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildLogo(bool isSmallScreen, bool isMobile) {
    final logoSize = isSmallScreen ? 80.0 : (isMobile ? 100.0 : 120.0);
    final iconSize = isSmallScreen ? 40.0 : (isMobile ? 50.0 : 60.0);
    
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                    Color(0xFF4CAF50),
                  ],
                ),
                borderRadius: BorderRadius.circular(logoSize * 0.25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.agriculture,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(bool isSmallScreen, bool isMobile) {
    final titleSize = isSmallScreen ? 24.0 : (isMobile ? 28.0 : 36.0);
    final subtitleSize = isSmallScreen ? 12.0 : (isMobile ? 14.0 : 16.0);
    
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'FARM Hub',
                        textStyle: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: isSmallScreen ? 1.5 : 3,
                        ),
                        speed: const Duration(milliseconds: 200),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Text(
                    'Farm Operations & Weather-Guided',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Agricultural Resource Management',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildSubtitle(bool isSmallScreen, bool isMobile) {
    final fontSize = isSmallScreen ? 11.0 : (isMobile ? 12.0 : 14.0);
    final padding = isSmallScreen 
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : (isMobile 
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12));
    
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textOpacity,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Complete Sugarcane Farm Management Solution',
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatures(bool isSmallScreen, bool isMobile) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textOpacity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final spacing = isSmallScreen ? 12.0 : 20.0;
              
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _buildFeatureItem(Icons.agriculture, 'Sugar Records', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.inventory_2, 'Inventory', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.business, 'Suppliers', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.wb_sunny, 'Weather', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.psychology, 'Generate Insight', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.assessment, 'Reports', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.insights, 'View Insights', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.settings, 'Settings', isSmallScreen, isMobile),
                  _buildFeatureItem(Icons.delete_outline, 'Data Cleanup', isSmallScreen, isMobile),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, bool isSmallScreen, bool isMobile) {
    final iconSize = isSmallScreen ? 18.0 : (isMobile ? 20.0 : 24.0);
    final fontSize = isSmallScreen ? 10.0 : (isMobile ? 11.0 : 12.0);
    final padding = isSmallScreen 
        ? const EdgeInsets.all(8)
        : (isMobile 
            ? const EdgeInsets.all(10)
            : const EdgeInsets.all(12));
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: iconSize,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),
        SizedBox(
          width: isSmallScreen ? 70 : (isMobile ? 80 : 100),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 700;
              
              return AnimatedBuilder(
                animation: Listenable.merge([_textController, _loadingController]),
                builder: (context, child) {
                  // Combine fade-in and fade-out animations
                  final opacity = _textOpacity.value * (1.0 - _loadingOpacity.value);
                  
                  // Hide completely when opacity is very low
                  if (opacity < 0.01) {
                    return const SizedBox.shrink();
                  }
                  
                  return Opacity(
                    opacity: opacity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 16 : 20,
                          height: isSmallScreen ? 16 : 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          'Loading Farm Management System...',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw circles
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      30,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      20,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.2),
      15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
