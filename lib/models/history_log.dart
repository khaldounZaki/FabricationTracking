import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryLog {
  final String id; // log doc id
  final String sn; // shared per item
  final String role;
  final String userId;
  final String userName;
  final String status; // completed | duplicate
  final String? reason; // if duplicate
  final DateTime timestamp;

  HistoryLog({
    required this.id,
    required this.sn,
    required this.role,
    required this.userId,
    required this.userName,
    required this.status,
    required this.timestamp,
    this.reason,
  });

  Map<String, dynamic> toMap() => {
        'sn': sn,
        'role': role,
        'userId': userId,
        'userName': userName,
        'status': status,
        'reason': reason,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory HistoryLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return HistoryLog(
      id: doc.id,
      sn: d['sn'] as String,
      role: d['role'] as String,
      userId: d['userId'] as String,
      userName: d['userName'] as String? ?? '',
      status: d['status'] as String,
      reason: d['reason'] as String?,
      timestamp: (d['timestamp'] as Timestamp).toDate(),
    );
  }
}
