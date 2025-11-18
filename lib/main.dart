import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/screens/professional_splash.dart';
import 'package:sample/screens/professional_navigation.dart';
import 'package:sample/screens/main_navigation.dart';
import 'package:sample/screens/alerts.dart';
import 'package:sample/screens/reports_screen.dart';
import 'package:sample/screens/suppliers.dart';
import 'package:sample/screens/insights.dart';
import 'package:sample/weather.dart';
import 'package:sample/inventory.dart';
import 'package:sample/sugar.dart';
import 'package:sample/services/supabase_service.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/consolidated_service.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/utils/global_error_handler.dart';
import 'package:sample/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize global error handling
  try {
    GlobalErrorHandler.initialize();
  } catch (e) {
    print('⚠️ Error handler initialization failed: $e');
  }
  
  // Set system UI overlay style for professional look
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2E7D32),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (e) {
    print('⚠️ System UI setup failed: $e');
  }
  
  // Initialize services with better error handling
  await _initializeServices();
  
  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');
    
    // Initialize consolidated services
    final repository = LocalRepository.instance;
    await repository.initializeRealtimeSubscriptions();
    await ConsolidatedService.initialize();
    // Seed demo data for presentation if empty
    await repository.seedDemoData();
    // Initialize streams with current data
    await repository.initializeStreams();
    
    // Send system startup notification
    await AlertService.notifySystemStartup();
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('📝 App will continue with local storage only');
    
    // Initialize local repository even if Supabase fails
    try {
      final repository = LocalRepository.instance;
      await repository.seedDemoData();
      await repository.initializeStreams();
      print('✅ Local repository initialized successfully');
    } catch (localError) {
      print('⚠️ Local repository initialization failed: $localError');
      print('📝 App will start with minimal functionality');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hacienda Elizabeth - Agricultural Management System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const ProfessionalSplashScreen(),
        '/root': (context) => const ProfessionalNavigation(),
        '/main': (context) => const MainNavigationScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/suppliers': (context) => const SuppliersScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/weather': (context) => const Weather(),
        '/inventory': (context) => const Inventory(),
        '/sugar': (context) => const Sugar(),
      },
      initialRoute: '/',
    );
  }
}


