import 'package:flutter/material.dart';
import 'package:sample/models/alert.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/alert_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final LocalRepository _repo = LocalRepository.instance;
  List<AlertItem> _alerts = [];

  @override
  void initState() {
    super.initState();
    _load();
    _repo.alertsStream
        .listen((e) {
          if (mounted) {
            setState(() => _alerts = e.reversed.toList());
          }
        });
  }

  Future<void> _load() async {
    final list = await _repo.getAlerts();
    if (mounted) {
      setState(() => _alerts = list.reversed.toList());
    }
  }

  Future<void> _markAsRead(String alertId) async {
    await AlertService.markAsRead(alertId);
    _load(); // Refresh the list
  }

  Future<void> _markAllAsRead() async {
    await AlertService.markAllAsRead();
    _load(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsBar(),
              Expanded(
                child: _alerts.isEmpty
                    ? _buildEmptyState()
                    : _buildAlertsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF44336), Color(0xFFE57373)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage system notifications and alerts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (_alerts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_alerts.length} total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    if (_alerts.isEmpty) return const SizedBox.shrink();
    
    final unreadCount = _alerts.where((a) => !a.read).length;
    final warningCount = _alerts.where((a) => a.severity == 'warning').length;
    final errorCount = _alerts.where((a) => a.severity == 'error').length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _buildStatItem('Unread', unreadCount.toString(), Icons.mark_email_unread, Colors.blue),
          _buildStatItem('Warnings', warningCount.toString(), Icons.warning, Colors.orange),
          _buildStatItem('Errors', errorCount.toString(), Icons.error, Colors.red),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.mark_email_read, size: 16),
            label: const Text('Mark All Read', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up! No notifications at the moment.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(AlertItem alert) {
    final color = _getSeverityColor(alert.severity);
    final icon = _getSeverityIcon(alert.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: alert.read ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.read ? Colors.white.withValues(alpha: 0.1) : color.withValues(alpha: 0.3),
          width: alert.read ? 1 : 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: alert.read ? FontWeight.normal : FontWeight.bold,
            color: alert.read ? Colors.white70 : Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: TextStyle(
                color: alert.read ? Colors.white60 : Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
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
                      'NEW',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            alert.read ? Icons.mark_email_read : Icons.mark_email_unread,
            color: alert.read ? Colors.grey : color,
          ),
          onPressed: () => _markAsRead(alert.id),
        ),
        onTap: () => _markAsRead(alert.id),
      ),
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

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
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

}
