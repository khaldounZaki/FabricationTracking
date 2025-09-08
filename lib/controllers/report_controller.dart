import 'package:flutter/material.dart';
import '../models/history_log.dart';
import '../services/firestore_service.dart';

class ReportController with ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  /// All logs
  Stream<List<HistoryLog>> fetchLogs() {
    return _db.getLogs();
  }

  /// Logs for specific user
  Stream<List<HistoryLog>> fetchUserLogs(String userId) {
    return _db.getLogs().map(
          (logs) => logs.where((log) => log.userId == userId).toList(),
        );
  }

  /// Logs for specific serial number (SN)
  Stream<List<HistoryLog>> fetchSnLogs(String sn) {
    return _db.getLogs().map(
          (logs) => logs.where((log) => log.sn == sn).toList(),
        );
  }

  /// Logs for specific role (optional)
  Stream<List<HistoryLog>> fetchRoleLogs(String role) {
    return _db.getLogs().map(
          (logs) => logs.where((log) => log.role == role).toList(),
        );
  }
}
