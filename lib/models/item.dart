import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id; // item doc id (usually code)
  final String code;
  final String description;
  final int quantity;
  final String sn; // orderNumber-itemCode
  final DateTime createdAt;

  Item({
    required this.id,
    required this.code,
    required this.description,
    required this.quantity,
    required this.sn,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'code': code,
        'description': description,
        'quantity': quantity,
        'sn': sn,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Item(
      id: doc.id,
      code: data['code'] as String,
      description: data['description'] as String,
      quantity: data['quantity'] as int,
      sn: data['sn'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
