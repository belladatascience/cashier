import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StaffModel {
  final int? id;
  final String? docId;
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
    this.docId,
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

  /// Factory from Firebase Firestore DocumentSnapshot
  factory StaffModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return StaffModel(
        docId: snapshot.id,
        name: '',
        role: '',
      );
    }
    return StaffModel.fromMap(data, docId: snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory StaffModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return StaffModel(
        docId: doc.id,
        name: '',
        role: '',
      );
    }
    return StaffModel.fromMap(data, docId: doc.id);
  }

  /// Helper to convert dynamic raw bytes to Uint8List
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
  factory StaffModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawId = map['id'];
    final rawStoreId = map['store_id'] ?? map['storeId'];
    final nameStr = (map['name'] as String?) ?? '';

    return StaffModel(
      id: rawId is num
          ? rawId.toInt()
          : (rawId != null ? int.tryParse(rawId.toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      name: nameStr,
      role: (map['role'] as String?) ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      status: (map['status'] as String?) ?? 'Hadir',
      initials: map['initials'] as String? ?? _generateInitials(nameStr),
      avatarUrl: map['avatar_url'] as String? ?? map['avatarUrl'] as String?,
      avatarBytes: _parseBytes(map['avatar_bytes'] ?? map['avatarBytes']),
      storeId: rawStoreId is num
          ? rawStoreId.toInt()
          : (rawStoreId != null ? int.tryParse(rawStoreId.toString()) : null),
    );
  }

  static String _generateInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
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

  /// Convert to Firestore payload Map (stores bytes as Base64 String)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'status': status,
      'initials': initials ?? _generateInitials(name),
      'avatar_url': avatarUrl,
      if (avatarBytes != null) 'avatar_bytes': _bytesToBase64(avatarBytes),
      'store_id': storeId,
    };
  }

  /// Legacy Map for legacy views
  Map<String, dynamic> toLegacyMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
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

  /// CopyWith helper for state updates
  StaffModel copyWith({
    int? id,
    String? docId,
    String? name,
    String? role,
    String? phone,
    String? email,
    String? status,
    String? initials,
    String? avatarUrl,
    Uint8List? avatarBytes,
    int? storeId,
  }) {
    return StaffModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      storeId: storeId ?? this.storeId,
    );
  }

  String toJson() => json.encode(toMap());

  factory StaffModel.fromJson(String source) =>
      StaffModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StaffModel(id: $id, docId: $docId, name: $name, role: $role, status: $status, storeId: $storeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffModel &&
        other.id == id &&
        other.docId == docId &&
        other.name == name &&
        other.role == role &&
        other.phone == phone &&
        other.email == email &&
        other.status == status &&
        other.initials == initials &&
        other.avatarUrl == avatarUrl &&
        other.storeId == storeId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      docId,
      name,
      role,
      phone,
      email,
      status,
      initials,
      avatarUrl,
      storeId,
    );
  }
}
