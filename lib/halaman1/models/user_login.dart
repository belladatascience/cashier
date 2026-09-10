import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class UserModelSQL {
  final int? id;
  final String? docId;
  final String? uid;
  final String email;
  final String password;
  final String? nama;
  final String? nomor_hp;
  final String? asalKota;
  final String? cashierId;
  final String? role;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  UserModelSQL({
    this.id,
    this.docId,
    this.uid,
    required this.email,
    required this.password,
    this.nama,
    this.nomor_hp,
    this.asalKota,
    this.cashierId,
    this.role,
    this.avatarBytes,
    this.avatarUrl,
  });

  /// Factory from Firebase Firestore DocumentSnapshot
  factory UserModelSQL.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return UserModelSQL(
        docId: snapshot.id,
        uid: snapshot.id,
        email: '',
        password: '',
      );
    }
    return UserModelSQL.fromMap(data, docId: snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory UserModelSQL.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModelSQL(
        docId: doc.id,
        uid: doc.id,
        email: '',
        password: '',
      );
    }
    return UserModelSQL.fromMap(data, docId: doc.id);
  }

  /// Helper to convert dynamic bytes to Uint8List
  static Uint8List? _parseBytes(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is Blob) return value.bytes;
    if (value is String && value.isNotEmpty) {
      try {
        return base64Decode(value);
      } catch (_) {
        return null;
      }
    }
    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }
    return null;
  }

  /// Helper to convert bytes to base64 string
  static String? _bytesToBase64(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    return base64Encode(bytes);
  }

  /// Factory from Map with Firestore-safe parsing
  factory UserModelSQL.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawId = map['id'];

    return UserModelSQL(
      id: rawId is num
          ? rawId.toInt()
          : (rawId != null ? int.tryParse(rawId.toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      uid: map['uid'] as String? ?? docId ?? map['doc_id'] as String?,
      email: (map['email'] as String?) ?? '',
      password: (map['password'] as String?) ?? '',
      nama: (map['nama'] as String?) ?? (map['name'] as String?),
      nomor_hp: (map['nomor_hp'] as String?) ??
          (map['nomorHp'] as String?) ??
          (map['phone'] as String?),
      asalKota: (map['asalKota'] as String?) ??
          (map['asal_kota'] as String?) ??
          (map['city'] as String?),
      cashierId: (map['cashier_id'] as String?) ?? (map['cashierId'] as String?),
      role: (map['role'] as String?) ?? 'Barista / Kasir',
      avatarBytes: _parseBytes(map['avatar_bytes'] ?? map['avatarBytes']),
      avatarUrl: map['avatar_url'] as String? ?? map['avatarUrl'] as String?,
    );
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      if (uid != null) 'uid': uid,
      'email': email,
      'password': password,
      if (nama != null) 'nama': nama,
      if (nomor_hp != null) 'nomor_hp': nomor_hp,
      if (asalKota != null) 'asalKota': asalKota,
      if (cashierId != null) 'cashier_id': cashierId,
      if (role != null) 'role': role,
      if (avatarBytes != null) 'avatar_bytes': avatarBytes,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  /// Convert to Firestore payload Map (stores bytes as Base64 String)
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      if (uid != null) 'uid': uid,
      'email': email,
      'password': password,
      'nama': nama ?? '',
      'nomor_hp': nomor_hp ?? '',
      'asalKota': asalKota ?? '',
      'cashier_id': cashierId ?? '',
      'role': role ?? 'Barista / Kasir',
      if (avatarBytes != null) 'avatar_bytes': _bytesToBase64(avatarBytes),
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// CopyWith helper for state updates
  UserModelSQL copyWith({
    int? id,
    String? docId,
    String? uid,
    String? email,
    String? password,
    String? nama,
    String? nomor_hp,
    String? asalKota,
    String? cashierId,
    String? role,
    Uint8List? avatarBytes,
    String? avatarUrl,
  }) {
    return UserModelSQL(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      nama: nama ?? this.nama,
      nomor_hp: nomor_hp ?? this.nomor_hp,
      asalKota: asalKota ?? this.asalKota,
      cashierId: cashierId ?? this.cashierId,
      role: role ?? this.role,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModelSQL.fromJson(String source) =>
      UserModelSQL.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModelSQL(id: $id, docId: $docId, uid: $uid, email: $email, nama: $nama, cashierId: $cashierId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModelSQL &&
        other.id == id &&
        other.docId == docId &&
        other.uid == uid &&
        other.email == email &&
        other.password == password &&
        other.nama == nama &&
        other.nomor_hp == nomor_hp &&
        other.asalKota == asalKota &&
        other.cashierId == cashierId &&
        other.role == role;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      docId,
      uid,
      email,
      password,
      nama,
      nomor_hp,
      asalKota,
      cashierId,
      role,
    );
  }
}

/// Typedef alias for modern naming
typedef UserModel = UserModelSQL;
