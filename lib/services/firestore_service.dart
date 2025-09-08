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

  // ---------------- Users ----------------
  Future<void> addUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Stream<List<AppUser>> getUsers() {
    return _db.collection('users').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateUserStatus(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
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
}
