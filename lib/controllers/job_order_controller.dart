import 'package:flutter/foundation.dart';
import '../models/job_order.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class JobOrderController with ChangeNotifier {
  final _fs = FirestoreService.instance;

  Stream<List<JobOrder>> watchJobOrders() => _fs.watchJobOrders();

  Future<void> addJobOrder({
    required String orderNumber,
    required String clientName,
    required DateTime deliveryDate,
  }) async {
    final jo = JobOrder(
      id: orderNumber, // using orderNumber as doc id
      orderNumber: orderNumber,
      clientName: clientName,
      deliveryDate: deliveryDate,
      createdAt: DateTime.now(),
    );
    await _fs.addJobOrder(jo);
  }

  Stream<List<Item>> watchItems(String orderId) => _fs.watchItems(orderId);

  Future<void> addItem({
    required String orderId,
    required String code,
    required String description,
    required int quantity,
  }) async {
    final sn = '$orderId-$code';
    final item = Item(
      id: code,
      code: code,
      description: description,
      quantity: quantity,
      sn: sn,
      createdAt: DateTime.now(),
    );
    await _fs.addItem(orderId, item);
  }
}
