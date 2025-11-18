import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/widgets/notification_bell.dart';
import 'package:sample/constants/app_icons.dart';
import 'package:sample/theme/app_theme.dart';
import 'package:sample/widgets/sugarcane_background.dart';
import 'package:sample/widgets/responsive_builder.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTo;
  
  const HomeScreen({super.key, this.onNavigateTo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final LocalRepository _repo = LocalRepository.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
    
    // Listen to alert changes
    _repo.alertsStream.listen((alerts) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild when alerts change
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getSurfaceColor(context),
      body: SugarcaneGradientBackground(
        child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: ResponsiveUtils.getPadding(context),
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 30)),
                      _buildQuickActions(),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isSmallScreen = constraints.maxWidth < 400;
        final iconSize = isSmallScreen ? 24.0 : (isMobile ? 28.0 : 32.0);
        final titleSize = isSmallScreen ? 18.0 : (isMobile ? 22.0 : 28.0);
        final subtitleSize = isSmallScreen ? 12.0 : (isMobile ? 14.0 : 16.0);
        final iconPadding = isSmallScreen ? 12.0 : (isMobile ? 14.0 : 16.0);
        
        return Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(context),
                    AppTheme.getPrimaryColor(context).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                AppIcons.home,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : (isMobile ? 16 : 20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Hacienda Elizabeth',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: isSmallScreen ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Text(
                    'Your agricultural management dashboard',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 4 : 8),
            const NotificationBell(),
          ],
        );
      },
    );
  }


  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Sugar',
                AppIcons.add,
                AppColors.primary,
                () => _navigateToSugar(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Add Inventory',
                AppIcons.add,
                AppColors.secondary,
                () => _navigateToInventory(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Supplier',
                AppIcons.add,
                AppColors.accent,
                () => _navigateToSuppliers(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'View Insights',
                AppIcons.insights,
                AppColors.insights,
                () => _navigateToInsights(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSugar() {
    if (widget.onNavigateTo != null) {
      widget.onNavigateTo!(1); // Sugar Records is index 1
    }
  }

  void _navigateToInventory() {
    if (widget.onNavigateTo != null) {
      widget.onNavigateTo!(2); // Inventory is index 2
    }
  }

  void _navigateToInsights() {
    if (widget.onNavigateTo != null) {
      widget.onNavigateTo!(6); // Insights is index 6
    }
  }

  void _navigateToSuppliers() {
    if (widget.onNavigateTo != null) {
      widget.onNavigateTo!(3); // Suppliers is index 3
    }
  }

}
