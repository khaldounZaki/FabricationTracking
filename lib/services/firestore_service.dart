import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_order.dart';
import '../models/item.dart';
import '../models/part.dart';
import '../models/user.dart';
import '../models/history_log.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Job Orders ----------------
  Future<void> addJobOrder(JobOrder jobOrder) async {
    await _db.collection('job_orders').add(jobOrder.toMap());
  }

  Stream<List<JobOrder>> getJobOrders() {
    return _db.collection('job_orders').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => JobOrder.fromFirestore(doc)).toList());
  }

  Future<void> deleteJobOrder(String id) async {
    await _db.collection('job_orders').doc(id).delete();
  }

  // ---------------- Items ----------------
  Future<void> addItem(String jobOrderId, Item item) async {
    await _db
        .collection('job_orders')
        .doc(jobOrderId)
        .collection('items')
        .add(item.toMap());
  }

  Stream<List<Item>> getItems(String jobOrderId) {
    return _db
        .collection('job_orders')
        .doc(jobOrderId)
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList());
  }

  // ---------------- Parts ----------------
  Future<void> addPart(String jobOrderId, String itemId, Part part) async {
    await _db
        .collection('job_orders')
        .doc(jobOrderId)
        .collection('items')
        .doc(itemId)
        .collection('parts')
        .add(part.toMap());
  }

  Stream<List<Part>> getParts(String jobOrderId, String itemId) {
    return _db
        .collection('job_orders')
        .doc(jobOrderId)
        .collection('items')
        .doc(itemId)
        .collection('parts')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Part.fromFirestore(doc)).toList());
  }

  // ---------------- History ----------------
  Future<void> logAction(HistoryLog log) async {
    await _db.collection('history_logs').add(log.toMap());
  }

  Stream<List<HistoryLog>> getLogs() {
    return _db
        .collection('history_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HistoryLog.fromFirestore(doc)).toList());
  }

  Future<void> updateJobOrderStatus(String jobOrderId, String status) async {
    await _db
        .collection('job_orders')
        .doc(jobOrderId)
        .update({'status': status});
  }

  // // users stream
  // Stream<List<AppUser>> getUsers() {
  //   return _db.collection('users').snapshots().map((snap) =>
  //       snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList());
  // }

  // Future<void> updateUserStatus(String uid, bool isActive) async {
  //   await _db.collection('users').doc(uid).update({'isActive': isActive});
  // }

  // Future<void> updateUserInfo({
  //   required String uid,
  //   required String name,
  //   required String phone,
  //   required String photoUrl,
  //   required String role,
  // }) async {
  //   await _db.collection('users').doc(uid).update({
  //     'name': name,
  //     'phone': phone,
  //     'photoUrl': photoUrl,
  //     'role': role,
  //   });
  // }

  // Future<void> addUser({
  //   required String email,
  //   required String name,
  //   required String phone,
  //   required String photoUrl,
  //   required String role,
  // }) async {
  //   await _db.collection('users').add({
  //     'email': email,
  //     'isActive': true,
  //     'name': name,
  //     'phone': phone,
  //     'photoUrl': photoUrl,
  //     'role': role,
  //   });
  // }

  /// Stream all users as AppUser
  Stream<List<AppUser>> getUsers() {
    return _db.collection('users').snapshots().map(
          (snap) => snap.docs
              .map((d) =>
                  AppUser.fromMap(d.data() as Map<String, dynamic>?, d.id))
              .toList(),
        );
  }

  /// Fetch users once (optional)
  Future<List<AppUser>> getUsersOnce() async {
    final snap = await _db.collection('users').get();
    return snap.docs
        .map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>?, d.id))
        .toList();
  }

  /// Toggle active/block
  Future<void> updateUserStatus(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
  }

  /// Update user profile info (name, phone, photoUrl, role)
  Future<void> updateUserInfo({
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
    });
  }

  /// Add a manual user document (admin created)
  Future<void> addUser({
    required String email,
    required String name,
    required String phone,
    required String photoUrl,
    required String role,
    bool isActive = true,
  }) async {
    await _db.collection('users').add({
      'email': email,
      'isActive': isActive,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
    });
  }

  Future<List<Map<String, dynamic>>> getUserScanLogs(String userId) async {
    final snap = await _db
        .collection('scan_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> result = [];

    for (var doc in snap.docs) {
      final log = HistoryLog.fromFirestore(doc);

      // Get job order
      final jobDoc =
          await _db.collection('job_orders').doc(log.jobOrderId).get();
      final jobData = jobDoc.data() ?? {};

      // Get item
      final itemDoc = await _db
          .collection('job_orders')
          .doc(log.jobOrderId)
          .collection('items')
          .doc(log.itemId)
          .get();
      final itemData = itemDoc.data() ?? {};

      result.add({
        'jobOrderNumber': jobData['orderNumber'] ?? '',
        'clientName': jobData['clientName'] ?? '',
        'itemCode': itemData['code'] ?? '',
        'itemDescription': itemData['description'] ?? '',
        'sn': log.sn,
        'reason': log.reason ?? '',
        'timestamp': log.timestamp.toString(), // 👈 ensure string
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getScansForItem(
      String jobOrderId, String itemId) async {
    try {
      final snap = await _db
          .collection('scan_logs')
          .where('jobOrderId', isEqualTo: jobOrderId)
          .where('itemId', isEqualTo: itemId)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> result = [];

      for (var doc in snap.docs) {
        final data = doc.data();

        // fetch user who scanned
        final userDoc = await _db.collection('users').doc(data['userId']).get();
        final userData = userDoc.data() ?? {};

        result.add({
          'userId': data['userId'],
          'name': userData['name'] ?? '',
          'role': userData['role'] ?? '',
          'photoUrl': userData['photoUrl'] ?? '',
          'date': data['timestamp'] != null
              ? (data['timestamp'] as Timestamp)
                  .toDate()
                  .toString()
                  .split(' ')[0]
              : '',
        });
      }

      return result;
    } catch (e) {
      print("Error fetching scans for item: $e");
      return [];
    }
  }
}
