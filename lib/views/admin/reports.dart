import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/history_log.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _db = FirestoreService();
  DateTimeRange? _range;
  final _userFilterCtrl = TextEditingController();
  final _roleFilterCtrl = TextEditingController();

  bool _matchesFilters(HistoryLog log) {
    if (_range != null) {
      if (log.timestamp.isBefore(_range!.start) ||
          log.timestamp.isAfter(_range!.end)) {
        return false;
      }
    }
    final userText = _userFilterCtrl.text.trim();
    if (userText.isNotEmpty && !log.userId.contains(userText)) return false;

    final roleText = _roleFilterCtrl.text.trim();
    if (roleText.isNotEmpty &&
        !log.role.toLowerCase().contains(roleText.toLowerCase())) {
      return false;
    }

    return true;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDateRange: _range ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  void dispose() {
    _userFilterCtrl.dispose();
    _roleFilterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('y/MM/dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _userFilterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Filter by User ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _roleFilterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Role',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_range == null
                      ? 'Pick date range'
                      : '${DateFormat.yMMMd().format(_range!.start)} - ${DateFormat.yMMMd().format(_range!.end)}'),
                  onPressed: _pickRange,
                ),
                if (_range != null)
                  TextButton(
                    onPressed: () => setState(() => _range = null),
                    child: const Text('Clear range'),
                  )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<HistoryLog>>(
              stream: _db.getLogs(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final logs = (snap.data ?? []).where(_matchesFilters).toList();
                if (logs.isEmpty) {
                  return const Center(child: Text('No logs.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final l = logs[i];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('SN: ${l.sn}'),
                      subtitle: Text(
                          'Role: ${l.role} • User: ${l.userId} • ${dateFmt.format(l.timestamp)}'
                          '${l.reason != null && l.reason!.isNotEmpty ? '\nReason: ${l.reason}' : ''}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
