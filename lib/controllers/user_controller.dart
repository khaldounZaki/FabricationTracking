import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class UserController with ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  Stream<List<AppUser>> fetchUsers() {
    return _db.getUsers();
  }

  Future<void> updateUserStatus(String uid, bool isActive) async {
    await _db.updateUserStatus(uid, isActive);
    notifyListeners();
  }
}
