import 'package:flutter/material.dart';
import '../models/part.dart';
import '../services/firestore_service.dart';

class ItemController with ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  Stream<List<Part>> fetchParts(String jobOrderId, String itemId) {
    return _db.getParts(jobOrderId, itemId);
  }

  Future<void> addPart(String jobOrderId, String itemId, Part part) async {
    await _db.addPart(jobOrderId, itemId, part);
    notifyListeners();
  }
}
