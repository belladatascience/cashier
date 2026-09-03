import 'dart:typed_data';

class StaffModel {
  final int? id;
  final String name;
  final String role;
  final String? phone;
  final String? email;
  final String status;
  final String? initials;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final int? storeId;

  StaffModel({
    this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.status = 'Hadir',
    this.initials,
    this.avatarUrl,
    this.avatarBytes,
    this.storeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'status': status,
      'initials': initials ?? _generateInitials(name),
      'avatar_url': avatarUrl,
      'avatar_bytes': avatarBytes,
      'store_id': storeId,
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      status: map['status'] as String? ?? 'Hadir',
      initials: map['initials'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      avatarBytes: map['avatar_bytes'] as Uint8List?,
      storeId: map['store_id'] as int?,
    );
  }

  static String _generateInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1)
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'role': role,
      'status': status,
      'time': 'In: 07:00',
      'avatarUrl': avatarUrl,
      'avatarBytes': avatarBytes,
      'initials': initials ?? _generateInitials(name),
      'phone': phone,
      'email': email,
    };
  }
}
