// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final bool isActive;
  final String name;
  final String phone;
  final String photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.isActive,
    required this.name,
    required this.phone,
    required this.photoUrl,
  });

  /// Safe factory from Firestore map (handles missing fields)
  factory AppUser.fromMap(Map<String, dynamic>? m, String id) {
    final data = m ?? <String, dynamic>{};
    return AppUser(
      uid: id,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      isActive: data['isActive'] ?? false,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  /// If you ever receive a DocumentSnapshot directly:
  factory AppUser.fromDocument(DocumentSnapshot doc) {
    return AppUser.fromMap(doc.data() as Map<String, dynamic>?, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'isActive': isActive,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? role,
    bool? isActive,
    String? name,
    String? phone,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
