import 'package:flutter/material.dart';

class UserDataStore {
  static final UserDataStore instance = UserDataStore._internal();
  UserDataStore._internal();

  final ValueNotifier<Map<String, dynamic>> userDataNotifier = ValueNotifier({
    // Profile Akun Data (Edited in EditPersonalInfoScreen)
    'accountName': 'Bella Gita Asmara',
    'email': 'bella.gita@bgaco.com',
    'cashierId': 'BG188889',
    'phone': '087888848000',
    'accountRole': 'Senior Barista',

    // Profile Kasir Data (Edited in Profile screen via Edit Profil Kasir modal)
    'cashierName': 'Bella Saputra',
    'cashierRole': 'Senior Barista',
    'location': 'BGA Co. - Central Perk',
    'storeName': 'Bella Cafe',
    'shift': 'Pagi',
    'startDate': DateTime(2024, 1, 15),
    'avatarBytes': null,
  });

  // Persistent Shift Roster Pagi Notifier
  final ValueNotifier<List<Map<String, dynamic>>> shiftRosterPagiNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([
    {
      'name': 'Siti Aminah',
      'role': 'Head Barista',
      'shiftTime': '07:00 - 15:00',
      'status': 'Hadir',
      'time': 'In: 06:45',
      'imageUrl':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      'initials': 'SA',
    },
    {
      'name': 'Budi Santoso',
      'role': 'Pâtissier',
      'shiftTime': '07:00 - 15:00',
      'status': 'Hadir',
      'time': 'In: 06:50',
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      'initials': 'BS',
    },
    {
      'name': 'Rizky Pratama',
      'role': 'Kasir',
      'shiftTime': '07:00 - 15:00',
      'status': 'Istirahat',
      'time': '12:00 - 13:00',
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      'initials': 'RP',
    },
    {
      'name': 'Dewi Lestari',
      'role': 'Pelayan',
      'shiftTime': '07:00 - 15:00',
      'status': 'Hadir',
      'time': 'In: 06:55',
      'imageUrl': null,
      'initials': 'DW',
    },
    {
      'name': 'Ahmad Fadil',
      'role': 'Pelayan',
      'shiftTime': '07:00 - 15:00',
      'status': 'Belum Hadir',
      'time': '-',
      'imageUrl':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=300&q=80',
      'initials': 'AF',
    },
  ]);

  // Persistent Shift Roster Sore Notifier
  final ValueNotifier<List<Map<String, dynamic>>> shiftRosterSoreNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([
    {
      'name': 'Andi Wijaya',
      'role': 'Kasir Utama',
      'shiftTime': '15:00 - 23:00',
      'status': 'Hadir',
      'time': 'In: 14:50',
      'imageUrl': null,
      'initials': 'AW',
    },
    {
      'name': 'Maya Indah',
      'role': 'Runner',
      'shiftTime': '15:00 - 23:00',
      'status': 'Hadir',
      'time': 'In: 14:55',
      'imageUrl': null,
      'initials': 'MI',
    },
    {
      'name': 'Doni Setiawan',
      'role': 'Barista',
      'shiftTime': '15:00 - 23:00',
      'status': 'Belum Hadir',
      'time': '-',
      'imageUrl': null,
      'initials': 'DS',
    },
  ]);

  // Persistent Cafe Staff List (Used in Profile screen)
  final ValueNotifier<List<Map<String, dynamic>>> cafeStaffListNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([
    {
      'name': 'Siti Aminah',
      'role': 'Head Barista',
      'status': 'Hadir (Pagi)',
      'time': 'In: 06:45',
      'avatarUrl':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      'initials': 'SA',
      'badgeColor': const Color(0xFFDCFCE7),
      'textColor': const Color(0xFF166534),
    },
    {
      'name': 'Budi Santoso',
      'role': 'Pâtissier',
      'status': 'Hadir (Pagi)',
      'time': 'In: 06:50',
      'avatarUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      'initials': 'BS',
      'badgeColor': const Color(0xFFDCFCE7),
      'textColor': const Color(0xFF166534),
    },
    {
      'name': 'Rizky Pratama',
      'role': 'Kasir',
      'status': 'Istirahat',
      'time': '12:00 - 13:00',
      'avatarUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      'initials': 'RP',
      'badgeColor': const Color(0xFFFFEDD5),
      'textColor': const Color(0xFFC2410C),
    },
    {
      'name': 'Dewi Lestari',
      'role': 'Pelayan',
      'status': 'Shift Sore',
      'time': '15:00 - 23:00',
      'avatarUrl': null,
      'initials': 'DW',
      'badgeColor': const Color(0xFFE0F2FE),
      'textColor': const Color(0xFF0369A1),
    },
    {
      'name': 'Andi Wijaya',
      'role': 'Barista Assistant',
      'status': 'Libur',
      'time': 'Off Duty',
      'avatarUrl': null,
      'initials': 'AW',
      'badgeColor': const Color(0xFFF3F4F6),
      'textColor': const Color(0xFF4B5563),
    },
  ]);

  // Persistent Shift Calendar History (mapped by date key YYYY-MM-DD)
  final ValueNotifier<Map<String, Map<String, dynamic>>> shiftCalendarHistoryNotifier =
      ValueNotifier<Map<String, Map<String, dynamic>>>({});

  List<Map<String, dynamic>> get shiftRosterPagi =>
      shiftRosterPagiNotifier.value;
  List<Map<String, dynamic>> get shiftRosterSore =>
      shiftRosterSoreNotifier.value;
  List<Map<String, dynamic>> get cafeStaffList => cafeStaffListNotifier.value;

  static bool isStaffWorking(dynamic status) {
    if (status == null) return false;
    final s = status.toString().trim().toLowerCase();
    return s == 'hadir' ||
        s == 'on duty' ||
        s == 'istirahat' ||
        s == 'active' ||
        s == 'masuk';
  }

  String formatDateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool hasRecordedShiftOnDate(DateTime date) {
    return getStaffWhoWorkedOnDate(date).isNotEmpty;
  }

  Map<String, dynamic> getShiftDataForDate(DateTime date) {
    final key = formatDateKey(date);
    if (shiftCalendarHistoryNotifier.value.containsKey(key)) {
      return shiftCalendarHistoryNotifier.value[key]!;
    }
    // Return active base template
    return {
      'pagi': List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value),
      'sore': List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value),
    };
  }

  List<Map<String, dynamic>> getRosterPagiForDate(DateTime date) {
    final data = getShiftDataForDate(date);
    return List<Map<String, dynamic>>.from(data['pagi'] ?? []);
  }

  List<Map<String, dynamic>> getRosterSoreForDate(DateTime date) {
    final data = getShiftDataForDate(date);
    return List<Map<String, dynamic>>.from(data['sore'] ?? []);
  }

  List<Map<String, dynamic>> getStaffWhoWorkedOnDate(
    DateTime date, {
    int shiftFilter = 0, // 0: Semua, 1: Shift Pagi, 2: Shift Sore
  }) {
    final data = getShiftDataForDate(date);
    final List<Map<String, dynamic>> pagiList =
        ((data['pagi'] as List<dynamic>?) ?? [])
            .map((e) => {
                  ...Map<String, dynamic>.from(e as Map),
                  'shiftName': 'Shift Pagi',
                  'shiftBadgeColor': const Color(0xFFDCFCE7),
                  'shiftTextColor': const Color(0xFF166534),
                })
            .toList();

    final List<Map<String, dynamic>> soreList =
        ((data['sore'] as List<dynamic>?) ?? [])
            .map((e) => {
                  ...Map<String, dynamic>.from(e as Map),
                  'shiftName': 'Shift Sore',
                  'shiftBadgeColor': const Color(0xFFE0F2FE),
                  'shiftTextColor': const Color(0xFF0369A1),
                })
            .toList();

    if (shiftFilter == 1) {
      return pagiList;
    } else if (shiftFilter == 2) {
      return soreList;
    } else {
      return [...pagiList, ...soreList];
    }
  }

  void syncActiveRosterToDate(DateTime date) {
    final key = formatDateKey(date);
    final currentHistory =
        Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
    currentHistory[key] = {
      'pagi': List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value),
      'sore': List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value),
    };
    shiftCalendarHistoryNotifier.value = currentHistory;
  }

  void addStaffToRoster(
    int shiftTab,
    Map<String, dynamic> staff, {
    DateTime? activeDate,
  }) {
    final targetDate = activeDate ?? DateTime.now();
    final key = formatDateKey(targetDate);
    final currentHistory =
        Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
    final data = getShiftDataForDate(targetDate);
    final pagiList = List<Map<String, dynamic>>.from(data['pagi'] ?? []);
    final soreList = List<Map<String, dynamic>>.from(data['sore'] ?? []);

    if (shiftTab == 0) {
      pagiList.add(staff);
      shiftRosterPagiNotifier.value = pagiList;
    } else {
      soreList.add(staff);
      shiftRosterSoreNotifier.value = soreList;
    }

    currentHistory[key] = {
      'pagi': pagiList,
      'sore': soreList,
    };
    shiftCalendarHistoryNotifier.value = currentHistory;
  }

  void editStaffInRoster(
    int shiftTab,
    int index,
    Map<String, dynamic> updatedStaff, {
    DateTime? activeDate,
  }) {
    final targetDate = activeDate ?? DateTime.now();
    final key = formatDateKey(targetDate);
    final currentHistory =
        Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
    final data = getShiftDataForDate(targetDate);
    final pagiList = List<Map<String, dynamic>>.from(data['pagi'] ?? []);
    final soreList = List<Map<String, dynamic>>.from(data['sore'] ?? []);

    if (shiftTab == 0) {
      if (index >= 0 && index < pagiList.length) {
        pagiList[index] = updatedStaff;
        shiftRosterPagiNotifier.value = pagiList;
      }
    } else {
      if (index >= 0 && index < soreList.length) {
        soreList[index] = updatedStaff;
        shiftRosterSoreNotifier.value = soreList;
      }
    }

    currentHistory[key] = {
      'pagi': pagiList,
      'sore': soreList,
    };
    shiftCalendarHistoryNotifier.value = currentHistory;
  }

  void deleteStaffFromRoster(
    int shiftTab,
    int index, {
    DateTime? activeDate,
  }) {
    final targetDate = activeDate ?? DateTime.now();
    final key = formatDateKey(targetDate);
    final currentHistory =
        Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
    final data = getShiftDataForDate(targetDate);
    final pagiList = List<Map<String, dynamic>>.from(data['pagi'] ?? []);
    final soreList = List<Map<String, dynamic>>.from(data['sore'] ?? []);

    if (shiftTab == 0) {
      if (index >= 0 && index < pagiList.length) {
        pagiList.removeAt(index);
        shiftRosterPagiNotifier.value = pagiList;
      }
    } else {
      if (index >= 0 && index < soreList.length) {
        soreList.removeAt(index);
        shiftRosterSoreNotifier.value = soreList;
      }
    }

    currentHistory[key] = {
      'pagi': pagiList,
      'sore': soreList,
    };
    shiftCalendarHistoryNotifier.value = currentHistory;
  }

  void addCafeStaff(Map<String, dynamic> staff) {
    final list = List<Map<String, dynamic>>.from(cafeStaffListNotifier.value);
    list.add(staff);
    cafeStaffListNotifier.value = list;
  }

  void deleteCafeStaff(int index) {
    final list = List<Map<String, dynamic>>.from(cafeStaffListNotifier.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      cafeStaffListNotifier.value = list;
    }
  }

  void updateUserData(Map<String, dynamic> newData) {
    final current = Map<String, dynamic>.from(userDataNotifier.value);
    newData.forEach((key, value) {
      if (value != null) {
        current[key] = value;
      }
    });
    userDataNotifier.value = current;
  }
}

