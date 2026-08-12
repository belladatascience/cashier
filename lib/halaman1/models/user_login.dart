import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModelSQL {
  final int? id;
  final String email;
  final String password;
  final String? nama;
  final String? nomor_hp;
  final String? asalKota;
  UserModelSQL({
    this.id,
    required this.email,
    required this.password,
    this.nama,
    this.nomor_hp,
    this.asalKota,
  });

  // Mengonversi objek UserModelSQL menjadi Map<String, dynamic>
  // Format Map ini digunakan oleh sqflite untuk operasi insert/update ke database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'password': password,
      'nama': nama,
      'nomor_hp': nomor_hp,
      'asalKota': asalKota,
    };
  }

  // Factory constructor untuk membuat instance UserModelSQL dari Map hasil query SQLite.
  factory UserModelSQL.fromMap(Map<String, dynamic> map) {
    return UserModelSQL(
      id: map['id'] != null ? map['id'] as int : null,
      email: map['email'] as String,
      password: map['password'] as String,
      nama: map['nama'] != null ? map['nama'] as String : null,
      nomor_hp: map['nomor_hp'] != null ? map['nomor_hp'] as String : null,
      asalKota: map['asalKota'] != null ? map['asalKota'] as String : null,
    );
  }

  // Mengonversi objek menjadi format string JSON.
  String toJson() => json.encode(toMap());

  // Factory constructor untuk membuat instance UserModelSQL dari string JSON.
  factory UserModelSQL.fromJson(String source) =>
      UserModelSQL.fromMap(json.decode(source) as Map<String, dynamic>);
}
