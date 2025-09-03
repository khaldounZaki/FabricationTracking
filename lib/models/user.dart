class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String
      role; // admin | solid designer | welder | polisher | cleaner | quality checker | installer
  final bool active;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.active,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role,
        'active': active,
        'photoUrl': photoUrl,
      };

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) => AppUser(
        uid: uid,
        email: data['email'] as String,
        displayName: data['displayName'] as String? ?? '',
        role: data['role'] as String,
        active: data['active'] as bool? ?? false,
        photoUrl: data['photoUrl'] as String?,
      );
}
