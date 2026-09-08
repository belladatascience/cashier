import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cashier/halaman1/database/database_helper.dart';
import 'package:cashier/halaman1/models/shift_model.dart';
import 'package:cashier/halaman1/models/staff_model.dart';
import 'package:cashier/halaman1/models/user_login.dart';
import 'package:flutter/material.dart';

class UserDataStore {
  static final UserDataStore instance = UserDataStore._internal();
  UserDataStore._internal();

  bool _isInitialized = false;

  final ValueNotifier<Map<String, dynamic>> userDataNotifier = ValueNotifier({
    // Profile Akun Data
    'accountName': 'Bella Gita Asmara',
    'email': 'bella.gita@bgaco.com',
    'cashierId': 'BG188889',
    'phone': '087888848000',
    'accountRole': 'Senior Barista',

    // Profile Kasir Data
    'cashierName': 'Bella Gita Asmara',
    'cashierRole': 'Senior Barista',
    'location': 'Jakarta',
    'storeName': 'Bella Cafe',
    'shift': 'Pagi',
    'startDate': DateTime(2024, 1, 15),
    'avatarBytes': null,
    'userId': 1,
  });

  final ValueNotifier<List<Map<String, dynamic>>> shiftRosterPagiNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final ValueNotifier<List<Map<String, dynamic>>> shiftRosterSoreNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final ValueNotifier<List<Map<String, dynamic>>> cafeStaffListNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final ValueNotifier<Map<String, Map<String, dynamic>>>
  shiftCalendarHistoryNotifier =
      ValueNotifier<Map<String, Map<String, dynamic>>>({});

  List<Map<String, dynamic>> get shiftRosterPagi =>
      shiftRosterPagiNotifier.value;
  List<Map<String, dynamic>> get shiftRosterSore =>
      shiftRosterSoreNotifier.value;
  List<Map<String, dynamic>> get cafeStaffList => cafeStaffListNotifier.value;

  String formatDateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> initFromDatabase() async {
    if (_isInitialized) return;
    await reloadUserData();
    await reloadStaffList();
    await reloadShiftsForDate(DateTime.now());
    _isInitialized = true;
  }

  Future<void> reloadUserData() async {
    try {
      final session = await DataBaseHelper().getActiveSession();
      if (session != null) {
        final current = Map<String, dynamic>.from(userDataNotifier.value);
        current['accountName'] = session['user_name'] ?? current['accountName'];
        current['email'] = session['email'] ?? current['email'];
        current['cashierId'] = session['cashier_id'] ?? current['cashierId'];
        current['accountRole'] = session['role'] ?? current['accountRole'];
        current['phone'] = session['phone'] ?? current['phone'];
        current['cashierName'] = session['user_name'] ?? current['cashierName'];
        current['cashierRole'] = session['role'] ?? current['cashierRole'];
        current['storeName'] = session['store_name'] ?? current['storeName'];
        current['location'] = session['store_location'] ?? current['location'];
        current['shift'] = session['shift'] ?? current['shift'];
        current['avatarBytes'] =
            session['avatar_bytes'] ?? current['avatarBytes'];
        current['userId'] = session['user_id'] ?? current['userId'];
        userDataNotifier.value = current;
      }
    } catch (e) {
      debugPrint('Error loading active session: $e');
    }
  }

  Future<void> reloadStaffList() async {
    try {
      final staffList = await DataBaseHelper().getAllStaff();
      final list = staffList.map((s) => s.toLegacyMap()).toList();
      cafeStaffListNotifier.value = list;
    } catch (e) {
      debugPrint('Error loading staff list: $e');
    }
  }

  Future<void> reloadShiftsForDate(DateTime date) async {
    try {
      final key = formatDateKey(date);
      final shifts = await DataBaseHelper().getShiftsForDate(key);

      final List<Map<String, dynamic>> pagi = [];
      final List<Map<String, dynamic>> sore = [];

      for (final s in shifts) {
        if (s.shiftType.toLowerCase() == 'pagi') {
          pagi.add(s.toLegacyMap());
        } else {
          sore.add(s.toLegacyMap());
        }
      }

      shiftRosterPagiNotifier.value = pagi;
      shiftRosterSoreNotifier.value = sore;

      final history = Map<String, Map<String, dynamic>>.from(
        shiftCalendarHistoryNotifier.value,
      );
      history[key] = {'pagi': pagi, 'sore': sore};
      shiftCalendarHistoryNotifier.value = history;
    } catch (e) {
      debugPrint('Error loading shifts for date: $e');
    }
  }

  List<Map<String, dynamic>> getRosterPagiForDate(DateTime date) {
    final data = getShiftDataForDate(date);
    return List<Map<String, dynamic>>.from(data['pagi'] ?? []);
  }

  List<Map<String, dynamic>> getRosterSoreForDate(DateTime date) {
    final data = getShiftDataForDate(date);
    return List<Map<String, dynamic>>.from(data['sore'] ?? []);
  }

  Map<String, dynamic> getShiftDataForDate(DateTime date) {
    final key = formatDateKey(date);
    if (shiftCalendarHistoryNotifier.value.containsKey(key)) {
      return shiftCalendarHistoryNotifier.value[key]!;
    }
    return {
      'pagi': List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value),
      'sore': List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value),
    };
  }

  List<Map<String, dynamic>> getStaffWhoWorkedOnDate(
    DateTime date, {
    int shiftFilter = 0,
  }) {
    final data = getShiftDataForDate(date);
    final List<Map<String, dynamic>> pagiList =
        ((data['pagi'] as List<dynamic>?) ?? [])
            .map(
              (e) => {
                ...Map<String, dynamic>.from(e as Map),
                'shiftName': 'Shift Pagi',
                'shiftBadgeColor': const Color(0xFFDCFCE7),
                'shiftTextColor': const Color(0xFF166534),
              },
            )
            .toList();

    final List<Map<String, dynamic>> soreList =
        ((data['sore'] as List<dynamic>?) ?? [])
            .map(
              (e) => {
                ...Map<String, dynamic>.from(e as Map),
                'shiftName': 'Shift Sore',
                'shiftBadgeColor': const Color(0xFFE0F2FE),
                'shiftTextColor': const Color(0xFF0369A1),
              },
            )
            .toList();

    if (shiftFilter == 1) {
      return pagiList;
    } else if (shiftFilter == 2) {
      return soreList;
    } else {
      return [...pagiList, ...soreList];
    }
  }

  bool hasRecordedShiftOnDate(DateTime date) {
    final key = formatDateKey(date);
    if (shiftCalendarHistoryNotifier.value.containsKey(key)) {
      return true;
    }
    return getStaffWhoWorkedOnDate(date).isNotEmpty;
  }

  Future<void> syncActiveRosterToDate(DateTime date) async {
    final key = formatDateKey(date);
    for (final staff in shiftRosterPagi) {
      final model = ShiftModel(
        staffName: staff['name'] as String? ?? 'Staf Pagi',
        role: staff['role'] as String? ?? 'Barista',
        shiftType: 'Pagi',
        dateKey: key,
        status: staff['status'] as String? ?? 'Hadir',
        checkInTime: staff['time'] as String? ?? 'In: 07:00',
        storeName: userDataNotifier.value['storeName'] ?? 'Bella Cafe',
        avatarUrl: staff['imageUrl'] as String?,
        initials: staff['initials'] as String?,
      );
      await DataBaseHelper().insertShift(model);
    }

    for (final staff in shiftRosterSore) {
      final model = ShiftModel(
        staffName: staff['name'] as String? ?? 'Staf Sore',
        role: staff['role'] as String? ?? 'Barista',
        shiftType: 'Sore',
        dateKey: key,
        status: staff['status'] as String? ?? 'Hadir',
        checkInTime: staff['time'] as String? ?? 'In: 15:00',
        storeName: userDataNotifier.value['storeName'] ?? 'Bella Cafe',
        avatarUrl: staff['imageUrl'] as String?,
        initials: staff['initials'] as String?,
      );
      await DataBaseHelper().insertShift(model);
    }

    await reloadShiftsForDate(date);
  }

  static bool isStaffWorking(dynamic status) {
    if (status == null) return false;
    final s = status.toString().trim().toLowerCase();
    return s == 'hadir' ||
        s == 'on duty' ||
        s == 'istirahat' ||
        s == 'active' ||
        s == 'masuk';
  }

  Future<void> addStaffToRoster(
    int shiftTab,
    Map<String, dynamic> staff, {
    DateTime? activeDate,
  }) async {
    final targetDate = activeDate ?? DateTime.now();
    final dateKey = formatDateKey(targetDate);
    final shiftType = shiftTab == 0 ? 'Pagi' : 'Sore';

    final model = ShiftModel(
      staffName: staff['name'] as String? ?? 'Staf Baru',
      role: staff['role'] as String? ?? 'Barista',
      shiftType: shiftType,
      dateKey: dateKey,
      status: staff['status'] as String? ?? 'Hadir',
      checkInTime:
          staff['time'] as String? ??
          (shiftTab == 0 ? 'In: 07:00' : 'In: 15:00'),
      storeName: userDataNotifier.value['storeName'] ?? 'Bella Cafe',
      avatarUrl: staff['imageUrl'] as String?,
      initials: staff['initials'] as String?,
    );

    await DataBaseHelper().insertShift(model);
    await reloadShiftsForDate(targetDate);
  }

  Future<void> editStaffInRoster(
    int shiftTab,
    int index,
    Map<String, dynamic> updatedStaff, {
    DateTime? activeDate,
  }) async {
    final targetDate = activeDate ?? DateTime.now();
    final shiftType = shiftTab == 0 ? 'Pagi' : 'Sore';
    final currentList = shiftTab == 0 ? shiftRosterPagi : shiftRosterSore;

    if (index >= 0 && index < currentList.length) {
      final oldItem = currentList[index];
      final shiftId = oldItem['id'] as int?;

      final model = ShiftModel(
        id: shiftId,
        staffName: updatedStaff['name'] as String? ?? oldItem['name'],
        role: updatedStaff['role'] as String? ?? oldItem['role'],
        shiftType: shiftType,
        dateKey: formatDateKey(targetDate),
        status: updatedStaff['status'] as String? ?? oldItem['status'],
        checkInTime: updatedStaff['time'] as String? ?? oldItem['time'],
        storeName: userDataNotifier.value['storeName'] ?? 'Bella Cafe',
        avatarUrl: updatedStaff['imageUrl'] as String?,
        initials: updatedStaff['initials'] as String?,
      );

      if (shiftId != null) {
        await DataBaseHelper().updateShift(model);
      }
      await reloadShiftsForDate(targetDate);
    }
  }

  Future<void> deleteStaffFromRoster(
    int shiftTab,
    int index, {
    DateTime? activeDate,
  }) async {
    final targetDate = activeDate ?? DateTime.now();
    final currentList = shiftTab == 0 ? shiftRosterPagi : shiftRosterSore;

    if (index >= 0 && index < currentList.length) {
      final item = currentList[index];
      final shiftId = item['id'] as int?;
      if (shiftId != null) {
        await DataBaseHelper().deleteShift(shiftId);
      }
      await reloadShiftsForDate(targetDate);
    }
  }

  Future<void> addCafeStaff(Map<String, dynamic> staff) async {
    final model = StaffModel(
      name: staff['name'] as String,
      role: staff['role'] as String,
      phone: staff['phone'] as String?,
      email: staff['email'] as String?,
      status: staff['status'] as String? ?? 'Hadir',
      initials: staff['initials'] as String?,
      avatarUrl: staff['avatarUrl'] as String?,
      avatarBytes: staff['avatarBytes'] as Uint8List?,
    );

    await DataBaseHelper().insertStaff(model);
    await reloadStaffList();
  }

  Future<void> deleteCafeStaff(int index) async {
    if (index >= 0 && index < cafeStaffList.length) {
      final staff = cafeStaffList[index];
      final staffId = staff['id'] as int?;
      if (staffId != null) {
        await DataBaseHelper().deleteStaff(staffId);
      }
      await reloadStaffList();
    }
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    final current = Map<String, dynamic>.from(userDataNotifier.value);
    newData.forEach((key, value) {
      if (value != null) {
        current[key] = value;
      }
    });
    userDataNotifier.value = current;

    // Persist to active_session in SQLite
    final sessionData = {
      'user_id': current['userId'] ?? 1,
      'user_name':
          current['accountName'] ??
          current['cashierName'] ??
          'Bella Gita Asmara',
      'email': current['email'] ?? 'bella.gita@bgaco.com',
      'cashier_id': current['cashierId'] ?? 'BG188889',
      'role':
          current['accountRole'] ?? current['cashierRole'] ?? 'Senior Barista',
      'store_name': current['storeName'] ?? 'Bella Cafe',
      'store_location': current['location'] ?? 'Jakarta',
      'shift': current['shift'] ?? 'Pagi',
      'phone': current['phone'] ?? '087888848000',
      'avatar_bytes': current['avatarBytes'] as Uint8List?,
      'login_time': DateTime.now().toIso8601String(),
    };

    await DataBaseHelper().saveActiveSession(sessionData);

    // Update users table in SQLite
    if (current['userId'] != null) {
      final userModel = UserModelSQL(
        id: current['userId'] as int?,
        email: current['email'] as String? ?? 'bella.gita@bgaco.com',
        password: '123',
        nama: current['accountName'] as String?,
        nomor_hp: current['phone'] as String?,
        cashierId: current['cashierId'] as String?,
        role: current['accountRole'] as String?,
        avatarBytes: current['avatarBytes'] as Uint8List?,
      );
      await DataBaseHelper().updateUser(userModel);
    }

    // Sync to Firestore if Firebase user is logged in
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nama': current['accountName'] ?? current['cashierName'],
          'email': current['email'],
          'cashierId': current['cashierId'],
          'role': current['accountRole'] ?? current['cashierRole'],
          'nomor_hp': current['phone'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore profile sync error (non-fatal): $e');
    }
  }
}
