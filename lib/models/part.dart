import 'package:cloud_firestore/cloud_firestore.dart';

class Part {
  final String id;
  final String itemId;
  final String description;
  final String sn;
  final DateTime createdAt;

  Part({
    required this.id,
    required this.itemId,
    required this.description,
    required this.sn,
    required this.createdAt,
  });

  factory Part.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Part(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      description: data['description'] ?? '',
      sn: data['sn'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'description': description,
      'sn': sn,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
