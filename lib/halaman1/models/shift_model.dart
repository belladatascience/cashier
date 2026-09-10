import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftModel {
  final int? id;
  final String? docId;
  final int? staffId;
  final String staffName;
  final String role;
  final String shiftType; // 'Pagi', 'Sore', 'Middle'
  final String dateKey; // 'YYYY-MM-DD'
  final String status; // 'Hadir', 'Istirahat', 'Belum Hadir', 'Libur'
  final String checkInTime; // 'In: 06:45' or '-'
  final String storeName;
  final String? avatarUrl;
  final String? initials;

  ShiftModel({
    this.id,
    this.docId,
    this.staffId,
    required this.staffName,
    required this.role,
    required this.shiftType,
    required this.dateKey,
    this.status = 'Hadir',
    this.checkInTime = 'In: 07:00',
    this.storeName = 'Bella Cafe',
    this.avatarUrl,
    this.initials,
  });

  /// Factory from Firebase Firestore DocumentSnapshot
  factory ShiftModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return ShiftModel(
        docId: snapshot.id,
        staffName: '',
        role: '',
        shiftType: 'Pagi',
        dateKey: '',
      );
    }
    return ShiftModel.fromMap(data, docId: snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory ShiftModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return ShiftModel(
        docId: doc.id,
        staffName: '',
        role: '',
        shiftType: 'Pagi',
        dateKey: '',
      );
    }
    return ShiftModel.fromMap(data, docId: doc.id);
  }

  /// Factory from Map with Firestore-safe parsing
  factory ShiftModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawId = map['id'];
    final rawStaffId = map['staff_id'] ?? map['staffId'];

    return ShiftModel(
      id: rawId is num
          ? rawId.toInt()
          : (rawId != null ? int.tryParse(rawId.toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      staffId: rawStaffId is num
          ? rawStaffId.toInt()
          : (rawStaffId != null ? int.tryParse(rawStaffId.toString()) : null),
      staffName: (map['staff_name'] as String?) ?? (map['staffName'] as String?) ?? '',
      role: (map['role'] as String?) ?? '',
      shiftType: (map['shift_type'] as String?) ?? (map['shiftType'] as String?) ?? 'Pagi',
      dateKey: (map['date_key'] as String?) ?? (map['dateKey'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'Hadir',
      checkInTime: (map['check_in_time'] as String?) ??
          (map['checkInTime'] as String?) ??
          'In: 07:00',
      storeName: (map['store_name'] as String?) ??
          (map['storeName'] as String?) ??
          'Bella Cafe',
      avatarUrl: map['avatar_url'] as String? ?? map['avatarUrl'] as String?,
      initials: map['initials'] as String?,
    );
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      'staff_id': staffId,
      'staff_name': staffName,
      'role': role,
      'shift_type': shiftType,
      'date_key': dateKey,
      'status': status,
      'check_in_time': checkInTime,
      'store_name': storeName,
      'avatar_url': avatarUrl,
      'initials': initials,
    };
  }

  /// Convert to Firestore payload Map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'staff_id': staffId,
      'staff_name': staffName,
      'role': role,
      'shift_type': shiftType,
      'date_key': dateKey,
      'status': status,
      'check_in_time': checkInTime,
      'store_name': storeName,
      'avatar_url': avatarUrl,
      'initials': initials,
    };
  }

  /// Legacy Map for legacy views
  Map<String, dynamic> toLegacyMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      'name': staffName,
      'role': role,
      'shiftTime': shiftType.toLowerCase() == 'pagi'
          ? '07:00 - 15:00'
          : '15:00 - 23:00',
      'status': status,
      'time': checkInTime,
      'imageUrl': avatarUrl,
      'initials':
          initials ?? (staffName.isNotEmpty ? staffName.substring(0, 1) : 'S'),
      'storeName': storeName,
    };
  }

  /// CopyWith helper for state updates
  ShiftModel copyWith({
    int? id,
    String? docId,
    int? staffId,
    String? staffName,
    String? role,
    String? shiftType,
    String? dateKey,
    String? status,
    String? checkInTime,
    String? storeName,
    String? avatarUrl,
    String? initials,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      role: role ?? this.role,
      shiftType: shiftType ?? this.shiftType,
      dateKey: dateKey ?? this.dateKey,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      storeName: storeName ?? this.storeName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      initials: initials ?? this.initials,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShiftModel.fromJson(String source) =>
      ShiftModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ShiftModel(id: $id, docId: $docId, staffName: $staffName, role: $role, shiftType: $shiftType, dateKey: $dateKey, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftModel &&
        other.id == id &&
        other.docId == docId &&
        other.staffId == staffId &&
        other.staffName == staffName &&
        other.role == role &&
        other.shiftType == shiftType &&
        other.dateKey == dateKey &&
        other.status == status &&
        other.checkInTime == checkInTime &&
        other.storeName == storeName &&
        other.avatarUrl == avatarUrl &&
        other.initials == initials;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      docId,
      staffId,
      staffName,
      role,
      shiftType,
      dateKey,
      status,
      checkInTime,
      storeName,
      avatarUrl,
      initials,
    );
  }
}
