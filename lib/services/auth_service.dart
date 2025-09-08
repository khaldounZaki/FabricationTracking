import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign in with email & password
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  /// Register new user → inactive by default, no role yet
  Future<void> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update Firebase Auth display name
    await cred.user!.updateDisplayName(displayName);

    // Save to Firestore with inactive status
    final appUser = AppUser(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
      role: "pending", // no role until admin assigns
      isActive: false, // must wait for admin approval
    );

    await _db.collection("users").doc(appUser.uid).set(appUser.toMap());
  }

  /// Login existing user
  Future<User?> loginUser(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream of FirebaseAuth user
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/user.dart';
// import 'firestore_service.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirestoreService _db = FirestoreService();

//   // Sign in with email & password
//   Future<User?> signIn(String email, String password) async {
//     final result = await _auth.signInWithEmailAndPassword(
//         email: email, password: password);
//     return result.user;
//   }

//   // Register new user (inactive by default)
//   Future<User?> register(String email, String password) async {
//     final result = await _auth.createUserWithEmailAndPassword(
//         email: email, password: password);
//     final user = result.user;
//     if (user != null) {
//       final newUser = AppUser(
//         uid: user.uid,
//         email: email,
//         role: 'worker',
//         isActive: false, // must be activated by admin
//       );
//       await _db.addUser(newUser);
//     }
//     return user;
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   // Stream for auth state
//   Stream<User?> get userChanges => _auth.authStateChanges();
// }
