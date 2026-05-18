class User {
  final int id;
  final String slug;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final bool isActive;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.slug,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.isActive,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isActive: json['is_active'] ?? true,
      role: json['role'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'is_active': isActive,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}