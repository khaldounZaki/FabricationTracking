import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryLog {
  final String id;
  final String sn;
  final String userId;
  final String role;
  final DateTime timestamp;
  final String? reason;

  HistoryLog({
    required this.id,
    required this.sn,
    required this.userId,
    required this.role,
    required this.timestamp,
    this.reason,
  });

  factory HistoryLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryLog(
      id: doc.id,
      sn: data['sn'] ?? '',
      userId: data['userId'] ?? '',
      role: data['role'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reason: data['reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sn': sn,
      'userId': userId,
      'role': role,
      'timestamp': Timestamp.fromDate(timestamp),
      'reason': reason,
    };
  }
}
