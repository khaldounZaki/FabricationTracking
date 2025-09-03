import 'package:cloud_firestore/cloud_firestore.dart';

class JobOrder {
  final String id; // doc id (use orderNumber or autoId)
  final String orderNumber;
  final String clientName;
  final DateTime deliveryDate;
  final DateTime createdAt;

  JobOrder({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.deliveryDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'orderNumber': orderNumber,
        'clientName': clientName,
        'deliveryDate': Timestamp.fromDate(deliveryDate),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory JobOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return JobOrder(
      id: doc.id,
      orderNumber: data['orderNumber'] as String,
      clientName: data['clientName'] as String,
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
