import 'package:flutter/material.dart';

/// Centralized icon constants to eliminate duplication across the app
class AppIcons {
  // Navigation Icons
  static const IconData home = Icons.home;
  static const IconData homeOutlined = Icons.home_outlined;
  
  static const IconData agriculture = Icons.agriculture;
  static const IconData agricultureOutlined = Icons.agriculture_outlined;
  
  static const IconData inventory = Icons.inventory_2;
  static const IconData inventoryOutlined = Icons.inventory_2_outlined;
  
  static const IconData business = Icons.business;
  static const IconData businessOutlined = Icons.business_outlined;
  
  static const IconData weather = Icons.wb_sunny;
  static const IconData weatherOutlined = Icons.wb_sunny_outlined;
  
  static const IconData psychology = Icons.psychology;
  static const IconData psychologyOutlined = Icons.psychology_outlined;
  
  static const IconData insights = Icons.insights;
  static const IconData insightsOutlined = Icons.insights_outlined;
  
  static const IconData assessment = Icons.assessment;
  static const IconData assessmentOutlined = Icons.assessment_outlined;
  
  static const IconData settings = Icons.settings;
  static const IconData settingsOutlined = Icons.settings_outlined;

  // Action Icons
  static const IconData add = Icons.add;
  static const IconData addCircle = Icons.add_circle_outline;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData archive = Icons.archive;
  static const IconData restore = Icons.restore;
  static const IconData folder = Icons.folder_open;
  static const IconData arrowForward = Icons.arrow_forward_ios;
  static const IconData list = Icons.list_alt;
  
  // Status Icons
  static const IconData check = Icons.check;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData info = Icons.info;
  
  // Feature Icons
  static const IconData money = Icons.attach_money;
  static const IconData payments = Icons.payments_rounded;
  static const IconData receipt = Icons.receipt_long;
  static const IconData height = Icons.height;
  static const IconData notification = Icons.notifications;
  static const IconData refresh = Icons.refresh;
  static const IconData download = Icons.download;
  static const IconData upload = Icons.upload;
  
  // System Icons
  static const IconData system = Icons.computer;
  static const IconData database = Icons.storage;
  static const IconData sync = Icons.sync;
  static const IconData cloud = Icons.cloud;
  
  // Chart Icons
  static const IconData chart = Icons.bar_chart;
  static const IconData analytics = Icons.analytics;
  static const IconData trending = Icons.trending_up;
  
  // Utility Icons
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData more = Icons.more_vert;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
}

/// Centralized color constants to maintain consistency
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF66BB6A);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryDark = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF64B5F6);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Feature Colors
  static const Color weather = Color(0xFF9C27B0);
  static const Color insights = Color(0xFF00BCD4);
  static const Color reports = Color(0xFFE91E63);
  static const Color settings = Color(0xFF607D8B);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF1A1F3A);
  static const Color card = Color(0xFF2D3748);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
}
