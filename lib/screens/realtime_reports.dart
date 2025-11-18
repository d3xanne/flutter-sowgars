import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/models/realtime_event.dart';
import 'package:sample/services/local_repository.dart';

class RealtimeReportsScreen extends StatefulWidget {
  const RealtimeReportsScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeReportsScreen> createState() => _RealtimeReportsScreenState();
}

class _RealtimeReportsScreenState extends State<RealtimeReportsScreen> {
  final LocalRepository _repo = LocalRepository.instance;
  List<RealtimeEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
    _repo.realtimeEventsStream.listen((e) {
      setState(() => _events = e.reversed.toList());
    });
  }

  Future<void> _load() async {
    final list = await _repo.getEvents();
    setState(() => _events = list.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayCount = _events
        .where((e) => DateFormat('yyyy-MM-dd').format(e.timestamp) == today)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Data & Reports'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _kpi('Events Today', todayCount.toString(), Icons.today_rounded,
                    Colors.deepPurple),
                _kpi('Total Events', _events.length.toString(),
                    Icons.timeline_rounded, Colors.indigo),
              ],
            ),
          ),
          Expanded(
            child: _events.isEmpty
                ? Center(
                    child: Text('No events yet',
                        style: TextStyle(color: Colors.grey[600])),
                  )
                : ListView.builder(
                    reverse: false,
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final ev = _events[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _colorForEntity(ev.entity).withValues(alpha: 0.15),
                          child: Icon(_iconForEntity(ev.entity),
                              color: _colorForEntity(ev.entity)),
                        ),
                        title: Text(ev.message,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${ev.entity} • ${ev.action} • ${DateFormat('yyyy-MM-dd HH:mm').format(ev.timestamp)}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(title, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForEntity(String entity) {
    switch (entity) {
      case 'sugar':
        return Colors.green;
      case 'inventory':
        return Colors.amber;
      case 'supplier':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _iconForEntity(String entity) {
    switch (entity) {
      case 'sugar':
        return Icons.grass_rounded;
      case 'inventory':
        return Icons.inventory_2_rounded;
      case 'supplier':
        return Icons.store_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }
}
