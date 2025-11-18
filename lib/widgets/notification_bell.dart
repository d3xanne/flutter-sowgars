import 'package:flutter/material.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/models/alert.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  List<AlertItem> _alerts = [];
  
  @override
  void initState() {
    super.initState();
    // Listen to stream updates for real-time notifications
    LocalRepository.instance.alertsStream.listen((alerts) {
      if (mounted) {
        setState(() {
          _alerts = alerts;
        });
        // Show a brief animation or haptic feedback for new notifications
        _showNotificationFeedback();
      }
    });
    
    // Load initial alerts
    _loadAlerts();
  }
  
  void _showNotificationFeedback() {
    // Add subtle animation or haptic feedback for new notifications
    // This could be enhanced with HapticFeedback.vibrate() if needed
  }

  Future<void> _loadAlerts() async {
    final alerts = await LocalRepository.instance.getAlerts();
    if (mounted) {
      setState(() {
        _alerts = alerts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _alerts.where((alert) => !alert.read).length;
    final totalCount = _alerts.length;
        
    // Responsive sizing based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final iconSize = isMobile ? 24.0 : 28.0; // Restored to reasonable size
    final padding = isMobile ? 8.0 : 10.0; // Restored to reasonable padding
    final borderRadius = isMobile ? 12.0 : 16.0; // Restored to reasonable border radius
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15), // Simple background
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(
              _getNotificationIcon(unreadCount),
              color: unreadCount > 0 ? Colors.red : Colors.white, // Red for unread, white for read
              size: iconSize,
            ),
            onPressed: () => _showNotificationPanel(context),
            tooltip: _getTooltipText(unreadCount, totalCount),
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(padding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          if (totalCount > 0)
            Positioned(
              right: isMobile ? 6 : 8,
              top: isMobile ? 6 : 8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  color: _getBadgeColor(unreadCount),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  boxShadow: [
                    BoxShadow(
                      color: _getBadgeColor(unreadCount).withValues(alpha: 0.4),
                      blurRadius: isMobile ? 4 : 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  minWidth: isMobile ? 18 : 20,
                  minHeight: isMobile ? 18 : 20,
                ),
                child: Text(
                  totalCount > 99 ? '99+' : totalCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }


  void _showNotificationPanel(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Refresh alerts before showing panel
    await _loadAlerts();
    
    // Also refresh the stream to ensure data is up to date
    await LocalRepository.instance.refreshAlertsStream();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: isMobile ? 0.7 : 0.6,
        minChildSize: isMobile ? 0.5 : 0.4,
        maxChildSize: isMobile ? 0.9 : 0.8,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isMobile ? 16 : 20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: isMobile ? 6 : 8),
                width: isMobile ? 30 : 40,
                height: isMobile ? 3 : 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 0),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isMobile ? 16 : 20),
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderIcon(isMobile),
                                SizedBox(width: isMobile ? 8 : 12),
                                Expanded(child: _buildHeaderTexts(isMobile)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildHeaderActions(isMobile),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildHeaderIcon(isMobile),
                            SizedBox(width: isMobile ? 8 : 12),
                            Expanded(child: _buildHeaderTexts(isMobile)),
                            Flexible(child: _buildHeaderActions(isMobile)),
                          ],
                        ),
                ),
              ),
              // Recent alerts
              Expanded(
                child: StreamBuilder<List<AlertItem>>(
                  stream: LocalRepository.instance.alertsStream,
                  initialData: _alerts,
                  builder: (context, snapshot) {
                    print('🔔 Notification panel - Connection state: ${snapshot.connectionState}');
                    print('🔔 Notification panel - Has data: ${snapshot.hasData}');
                    print('🔔 Notification panel - Data: ${snapshot.data?.length ?? 0} alerts');
                    
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading alerts: ${snapshot.error}'),
                      );
                    }
                    
                    final alerts = snapshot.data ?? [];
                    final recentAlerts = alerts.take(8).toList();
                    
                    print('🔔 Notification panel - Recent alerts: ${recentAlerts.length}');
                    
                    if (recentAlerts.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.agriculture_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No farm activities yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start adding sugar records, inventory, or supplier transactions\nto see real-time farm alerts here',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: recentAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = recentAlerts[index];
                        return _buildNotificationItem(context, alert);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, AlertItem alert) {
    final color = _getSeverityColor(alert.severity);
    final icon = _getAlertIcon(alert.title);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: alert.read ? const Color(0xFF2A2A2A) : const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.read ? Colors.grey[700]! : color.withValues(alpha: 0.5),
          width: alert.read ? 1 : 2,
        ),
        boxShadow: alert.read ? null : [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: alert.read ? FontWeight.normal : FontWeight.bold,
            color: alert.read ? Colors.grey[400] : Colors.white,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: TextStyle(
                color: alert.read ? Colors.grey[500] : Colors.grey[300],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey[500],
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (!alert.read)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      alert.severity.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            alert.read
                ? Icon(Icons.check_circle_outline, color: Colors.grey[600], size: 20)
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
            const SizedBox(width: 8),
            // Delete button
            IconButton(
              onPressed: () async {
                print('🔔 NotificationBell: Delete notification - ID: ${alert.id}');
                await AlertService.deleteAlert(alert.id);
                // Force refresh the notification bell state
                await _loadAlerts();
                // Also refresh the stream
                await LocalRepository.instance.refreshAlertsStream();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              tooltip: 'Delete notification',
            ),
          ],
        ),
        onTap: () async {
          print('🔔 NotificationBell: Notification tapped - ID: ${alert.id}, Read: ${alert.read}');
          // Mark as read if unread
          if (!alert.read) {
            await AlertService.markAsRead(alert.id);
            // Force refresh the notification bell state
            await _loadAlerts();
            // Also refresh the stream
            await LocalRepository.instance.refreshAlertsStream();
          }
          // Close panel
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHeaderIcon(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
      ),
      child: Icon(
        Icons.notifications_active,
        color: Colors.white,
        size: isMobile ? 20 : 24,
      ),
    );
  }

  Widget _buildHeaderTexts(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Notifications',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Monitor your farm operations in real-time',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActions(bool isMobile) {
    return Builder(
      builder: (context) {
        final alerts = _alerts;
        final unreadCount = alerts.where((alert) => !alert.read).length;
        final totalCount = alerts.length;

        final children = <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: unreadCount > 0
                  ? Colors.red
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$unreadCount/$totalCount unread',
              style: TextStyle(
                color: unreadCount > 0 ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: () async {
                print('🔔 NotificationBell: Mark All Read button pressed');
                await AlertService.markAllAsRead();
                await _loadAlerts();
                await LocalRepository.instance.refreshAlertsStream();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size(isMobile ? 0 : 88, 0),
              ),
              child: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () async {
              print('🔔 NotificationBell: Delete All button pressed');
              await AlertService.deleteAllAlerts();
              await _loadAlerts();
              await LocalRepository.instance.refreshAlertsStream();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size(isMobile ? 0 : 88, 0),
            ),
            child: const Text(
              'Delete All',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await _loadAlerts();
              await LocalRepository.instance.refreshAlertsStream();
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
            tooltip: 'Refresh Alerts',
          ),
        ];

        return Align(
          alignment:
              isMobile ? Alignment.centerLeft : Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment:
                isMobile ? WrapAlignment.start : WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Farm-specific notification icon
  IconData _getNotificationIcon(int unreadCount) {
    if (unreadCount > 0) {
      return Icons.notifications_active; // Active bell for unread notifications
    }
    return Icons.notifications_outlined; // Outlined bell for no unread notifications
  }

  // Farm-specific tooltip text
  String _getTooltipText(int unreadCount, int totalCount) {
    if (unreadCount > 0) {
      return 'Notifications ($unreadCount unread)';
    } else if (totalCount > 0) {
      return 'Notifications ($totalCount total)';
    }
    return 'Notifications - No alerts';
  }

  // Farm-specific badge colors
  Color _getBadgeColor(int unreadCount) {
    if (unreadCount > 0) {
      return const Color(0xFFE53E3E); // Red for urgent farm alerts
    }
    return const Color(0xFF38A169); // Green for general farm updates
  }

  // Get notification icon based on alert type
  IconData _getAlertIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('sugar') || titleLower.contains('monitoring')) {
      return Icons.agriculture;
    } else if (titleLower.contains('inventory') || titleLower.contains('stock')) {
      return Icons.inventory;
    } else if (titleLower.contains('supplier') || titleLower.contains('transaction')) {
      return Icons.local_shipping;
    } else if (titleLower.contains('weather')) {
      return Icons.wb_sunny;
    } else if (titleLower.contains('system')) {
      return Icons.settings;
    }
    return Icons.notifications;
  }

}

// Pulsing animation widget for unread notifications
class _PulsingContainer extends StatefulWidget {
  final Widget child;

  const _PulsingContainer({required this.child});

  @override
  State<_PulsingContainer> createState() => _PulsingContainerState();
}

class _PulsingContainerState extends State<_PulsingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
        return Opacity(
          opacity: 0.3 + (0.4 * _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

