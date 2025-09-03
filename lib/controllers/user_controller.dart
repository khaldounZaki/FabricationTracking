import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class UserController with ChangeNotifier {
  final _fs = FirestoreService.instance;

  Future<void> setActive(String uid, bool active) =>
      _fs.setUserActive(uid, active);
}
