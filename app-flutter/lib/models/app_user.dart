class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'seller',
        avatar: json['avatar'] as String?,
      );

  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  bool get isAdmin => role == 'admin';
}

