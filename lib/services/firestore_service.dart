import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_order.dart';
import '../models/item.dart';
import '../models/history_log.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();
  final _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference<Map<String, dynamic>> get _jobOrders =>
      _db.collection('jobOrders');

  // -------- Job Orders --------
  Future<void> addJobOrder(JobOrder jo) async {
    await _jobOrders.doc(jo.id).set(jo.toMap());
  }

  Stream<List<JobOrder>> watchJobOrders() {
    return _jobOrders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => JobOrder.fromDoc(d)).toList());
  }

  Future<JobOrder?> getJobOrder(String id) async {
    final doc = await _jobOrders.doc(id).get();
    if (!doc.exists) return null;
    return JobOrder.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // -------- Items (subcollection) --------
  CollectionReference<Map<String, dynamic>> itemsRef(String orderId) =>
      _jobOrders.doc(orderId).collection('items');

  Future<void> addItem(String orderId, Item item) async {
    await itemsRef(orderId).doc(item.id).set(item.toMap());
  }

  Stream<List<Item>> watchItems(String orderId) {
    return itemsRef(orderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Item.fromDoc(d)).toList());
  }

  // -------- Parts (subcollection under item) --------
  CollectionReference<Map<String, dynamic>> partsRef(
          String orderId, String itemId) =>
      itemsRef(orderId).doc(itemId).collection('parts');

  Future<void> addPart(
      String orderId, String itemId, String partDescription, String sn) async {
    await partsRef(orderId, itemId).add({
      'description': partDescription,
      'stickerSN': sn,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // -------- History (subcollection under item) --------
  CollectionReference<Map<String, dynamic>> historyRef(
          String orderId, String itemId) =>
      itemsRef(orderId).doc(itemId).collection('history');

  Future<void> addHistoryLog(
      String orderId, String itemId, HistoryLog log) async {
    await historyRef(orderId, itemId).add(log.toMap());
  }

  Stream<List<HistoryLog>> watchHistory(String orderId, String itemId) {
    return historyRef(orderId, itemId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => HistoryLog.fromDoc(d)).toList());
  }

  // -------- Users --------
  CollectionReference<Map<String, dynamic>> get usersRef =>
      _db.collection('users');

  Future<void> setUserActive(String uid, bool active) async {
    await usersRef.doc(uid).update({'active': active});
  }
}
