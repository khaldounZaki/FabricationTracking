import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Sign in with email & password
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// 🔹 Register new user → inactive by default, no role yet
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update Firebase Auth profile (optional)
    await cred.user!.updateDisplayName(name);

    // Save to Firestore
    final appUser = AppUser(
      uid: cred.user!.uid,
      email: email,
      role: "pending", // wait for admin assignment
      isActive: false, // must be approved by admin
      name: name,
      phone: "",
      photoUrl: "",
    );

    await _db.collection("users").doc(appUser.uid).set(appUser.toMap());
  }

  /// 🔹 Login existing user
  Future<User?> loginUser(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// 🔹 Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔹 Stream of FirebaseAuth user
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
