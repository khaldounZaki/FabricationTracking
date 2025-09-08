class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'pending',
      isActive: data['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'isActive': isActive,
    };
  }
}
