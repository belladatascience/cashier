class ShiftModel {
  final int? id;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      id: map['id'] as int?,
      staffId: map['staff_id'] as int?,
      staffName: map['staff_name'] as String,
      role: map['role'] as String,
      shiftType: map['shift_type'] as String,
      dateKey: map['date_key'] as String,
      status: map['status'] as String? ?? 'Hadir',
      checkInTime: map['check_in_time'] as String? ?? 'In: 07:00',
      storeName: map['store_name'] as String? ?? 'Bella Cafe',
      avatarUrl: map['avatar_url'] as String?,
      initials: map['initials'] as String?,
    );
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      if (id != null) 'id': id,
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
}
