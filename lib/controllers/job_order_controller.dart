import 'package:flutter/material.dart';
import '../models/job_order.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class JobOrderController with ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  List<JobOrder> jobOrders = [];
  bool isLoading = false;

  Stream<List<JobOrder>> fetchJobOrders() {
    return _db.getJobOrders();
  }

  Future<void> addJobOrder(JobOrder jobOrder) async {
    isLoading = true;
    notifyListeners();
    await _db.addJobOrder(jobOrder);
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteJobOrder(String id) async {
    await _db.deleteJobOrder(id);
  }

  Stream<List<Item>> fetchItems(String jobOrderId) {
    return _db.getItems(jobOrderId);
  }

  Future<void> addItem(String jobOrderId, Item item) async {
    await _db.addItem(jobOrderId, item);
  }
}
