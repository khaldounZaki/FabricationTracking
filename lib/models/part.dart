import 'package:cloud_firestore/cloud_firestore.dart';

class Part {
  final String id;
  final String itemId;
  final String description;
  final String sn;
  final int qty;
  final DateTime createdAt;

  Part({
    required this.id,
    required this.itemId,
    required this.description,
    required this.sn,
    this.qty = 1,
    required this.createdAt,
  });

  factory Part.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Part(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      description: data['description'] ?? '',
      sn: data['sn'] ?? '',
      qty: (data['qty'] is int) ? data['qty'] as int : int.tryParse('${data['qty']}') ?? 1,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'description': description,
      'sn': sn,
      'qty': qty,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
