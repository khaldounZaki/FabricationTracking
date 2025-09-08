import 'package:cloud_firestore/cloud_firestore.dart';

class JobOrder {
  final String id;
  final String clientName;
  final String orderNumber;
  final DateTime deliveryDate;
  final String status; // NEW

  JobOrder({
    required this.id,
    required this.clientName,
    required this.orderNumber,
    required this.deliveryDate,
    this.status = "In Progress", // default
  });

  factory JobOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobOrder(
      id: doc.id,
      clientName: data['clientName'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      status: data['status'] ?? "In Progress",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'orderNumber': orderNumber,
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'status': status,
    };
  }
}
