import 'dart:convert';
import 'dart:typed_data';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModelSQL {
  final int? id;
  final String email;
  final String password;
  final String? nama;
  final String? nomor_hp;
  final String? asalKota;
  final String? cashierId;
  final String? role;
  final Uint8List? avatarBytes;

  UserModelSQL({
    this.id,
    required this.email,
    required this.password,
    this.nama,
    this.nomor_hp,
    this.asalKota,
    this.cashierId,
    this.role,
    this.avatarBytes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'email': email,
      'password': password,
      'nama': nama,
      'nomor_hp': nomor_hp,
      'asalKota': asalKota,
      'cashier_id': cashierId,
      'role': role,
      'avatar_bytes': avatarBytes,
    };
  }

  factory UserModelSQL.fromMap(Map<String, dynamic> map) {
    return UserModelSQL(
      id: map['id'] != null ? map['id'] as int : null,
      email: map['email'] as String,
      password: (map['password'] as String?) ?? '',
      nama: map['nama'] != null ? map['nama'] as String : null,
      nomor_hp: map['nomor_hp'] != null ? map['nomor_hp'] as String : null,
      asalKota: map['asalKota'] != null ? map['asalKota'] as String : null,
      cashierId: map['cashier_id'] != null ? map['cashier_id'] as String : null,
      role: map['role'] != null ? map['role'] as String : null,
      avatarBytes: map['avatar_bytes'] as Uint8List?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModelSQL.fromJson(String source) =>
      UserModelSQL.fromMap(json.decode(source) as Map<String, dynamic>);
}
