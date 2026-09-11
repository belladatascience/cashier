import 'dart:async';
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
  StreamSubscription? _staffSubscription;
  StreamSubscription? _shiftsSubscription;
  StreamSubscription? _storesSubscription;
  DateTime _currentActiveDate = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  final ValueNotifier<List<String>> storeListNotifier =
      ValueNotifier<List<String>>([
        'Bella Cafe',
        'BGA Co. - Central Perk',
        'BGA Co. - Downtown Latte',
        'BGA Co. - Westside Brew',
      ]);

  final ValueNotifier<Map<String, Map<String, dynamic>>>
  shiftCalendarHistoryNotifier =
      ValueNotifier<Map<String, Map<String, dynamic>>>({});

  List<Map<String, dynamic>> get shiftRosterPagi =>
      shiftRosterPagiNotifier.value;
  List<Map<String, dynamic>> get shiftRosterSore =>
      shiftRosterSoreNotifier.value;
  List<Map<String, dynamic>> get cafeStaffList => cafeStaffListNotifier.value;
  List<String> get storeList => storeListNotifier.value;

  String formatDateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Initialize user, staff, stores, and shifts from Firebase
  Future<void> initFromDatabase() async {
    if (_isInitialized) return;
    await reloadUserData();
    await reloadStoreList();
    await reloadStaffList();
    await reloadShiftsForDate(DateTime.now());
    _startRealtimeListeners();
    _isInitialized = true;
  }

  /// Alias for initFromDatabase
  Future<void> initFromFirebase() async => initFromDatabase();

  /// Real-time listeners for Staff, Shifts, and Stores changes in Firestore
  void _startRealtimeListeners() {
    try {
      _staffSubscription?.cancel();
      _shiftsSubscription?.cancel();
      _storesSubscription?.cancel();

      // Listen to staff collection
      _staffSubscription = _firestore.collection('staff').snapshots().listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            reloadStaffList();
          }
        },
        onError: (e) => debugPrint('Firestore staff stream error: $e'),
      );

      // Listen to shift_roster collection
      _shiftsSubscription = _firestore.collection('shift_roster').snapshots().listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            reloadShiftsForDate(_currentActiveDate);
          }
        },
        onError: (e) => debugPrint('Firestore shift stream error: $e'),
      );

      // Listen to stores collection
      _storesSubscription = _firestore.collection('stores').snapshots().listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            reloadStoreList();
          }
        },
        onError: (e) => debugPrint('Firestore stores stream error: $e'),
      );
    } catch (e) {
      debugPrint('Error attaching realtime listeners: $e');
    }
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
      debugPrint('Error loading active session from Firebase: $e');
    }
  }

  Future<void> reloadStaffList() async {
    try {
      final staffList = await DataBaseHelper().getAllStaff();
      final list = staffList.map((s) => s.toLegacyMap()).toList();
      cafeStaffListNotifier.value = list;
    } catch (e) {
      debugPrint('Error loading staff list from Firebase: $e');
    }
  }

  List<Map<String, dynamic>> _getDefaultPagiShifts() => [
    {
      'id': 101,
      'name': 'Bella Gita Asmara',
      'role': 'Kasir Utama',
      'status': 'Hadir',
      'time': 'In: 06:55',
      'shiftTime': '07:00 - 15:00',
      'hours': '40',
      'phone': '087888848000',
      'email': 'bella.gita@bgaco.com',
      'initials': 'BG',
      'storeName': userDataNotifier.value['storeName'] ?? 'Bella Cafe',
    },
    {
      'id': 102,
      'name': 'Hendra Gunawan',
      'role': 'Head Barista',
      'status': 'Hadir',
      'time': 'In: 06:50',
      'shiftTime': '07:00 - 15:00',
      'hours': '40',
      'phone': '081234567890',
      'email': 'hendra.g@bgaco.com',
      'initials': 'HG',
      'storeName': userDataNotifier.value['storeName'] ?? 'Bella Cafe',
    },
  ];

  List<Map<String, dynamic>> _getDefaultSoreShifts() => [
    {
      'id': 201,
      'name': 'Dimas Prasetyo',
      'role': 'Barista',
      'status': 'Hadir',
      'time': 'In: 14:45',
      'shiftTime': '15:00 - 23:00',
      'hours': '40',
      'phone': '085712345678',
      'email': 'dimas.p@bgaco.com',
      'initials': 'DP',
      'storeName': userDataNotifier.value['storeName'] ?? 'Bella Cafe',
    },
    {
      'id': 202,
      'name': 'Siti Rahma',
      'role': 'Runner',
      'status': 'Hadir',
      'time': 'In: 15:00',
      'shiftTime': '15:00 - 23:00',
      'hours': '40',
      'phone': '089612345678',
      'email': 'siti.r@bgaco.com',
      'initials': 'SR',
      'storeName': userDataNotifier.value['storeName'] ?? 'Bella Cafe',
    },
  ];

  Future<void> reloadShiftsForDate(DateTime date) async {
    _currentActiveDate = date;
    final key = formatDateKey(date);
    try {
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

      final history = Map<String, Map<String, dynamic>>.from(
        shiftCalendarHistoryNotifier.value,
      );

      if (pagi.isNotEmpty || sore.isNotEmpty) {
        shiftRosterPagiNotifier.value = pagi;
        shiftRosterSoreNotifier.value = sore;
        history[key] = {'pagi': pagi, 'sore': sore};
      } else if (history.containsKey(key)) {
        shiftRosterPagiNotifier.value = List<Map<String, dynamic>>.from(history[key]!['pagi'] ?? []);
        shiftRosterSoreNotifier.value = List<Map<String, dynamic>>.from(history[key]!['sore'] ?? []);
      } else {
        final defPagi = _getDefaultPagiShifts();
        final defSore = _getDefaultSoreShifts();
        shiftRosterPagiNotifier.value = defPagi;
        shiftRosterSoreNotifier.value = defSore;
        history[key] = {'pagi': defPagi, 'sore': defSore};
      }

      shiftCalendarHistoryNotifier.value = history;
    } catch (e) {
      debugPrint('Error loading shifts for date from Firebase: $e');
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
    final activeStore = userDataNotifier.value['storeName'] ?? 'Bella Cafe';

    final List<Map<String, dynamic>> pagiList =
        ((data['pagi'] as List<dynamic>?) ?? [])
            .map(
              (e) => {
                ...Map<String, dynamic>.from(e as Map),
                'shiftName': 'Shift Pagi',
                'shiftBadgeColor': const Color(0xFFDCFCE7),
                'shiftTextColor': const Color(0xFF166534),
                'storeName': e['storeName'] ?? activeStore,
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
                'storeName': e['storeName'] ?? activeStore,
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
      final data = shiftCalendarHistoryNotifier.value[key]!;
      final pagi = (data['pagi'] as List?) ?? [];
      final sore = (data['sore'] as List?) ?? [];
      return pagi.isNotEmpty || sore.isNotEmpty;
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
        storeName: staff['storeName'] ?? (userDataNotifier.value['storeName'] ?? 'Bella Cafe'),
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
        storeName: staff['storeName'] ?? (userDataNotifier.value['storeName'] ?? 'Bella Cafe'),
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
    final targetDate = activeDate ?? _currentActiveDate;
    final dateKey = formatDateKey(targetDate);
    final shiftType = shiftTab == 0 ? 'Pagi' : 'Sore';
    final activeStore = userDataNotifier.value['storeName'] ?? 'Bella Cafe';

    final staffMap = {
      'id': staff['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': staff['name'] ?? 'Staf Baru',
      'role': staff['role'] ?? 'Barista',
      'status': staff['status'] ?? 'Hadir',
      'time': staff['time'] ?? (shiftTab == 0 ? 'In: 07:00' : 'In: 15:00'),
      'shiftTime': shiftType == 'Pagi' ? '07:00 - 15:00' : '15:00 - 23:00',
      'hours': staff['hours'] ?? '40',
      'phone': staff['phone'],
      'email': staff['email'],
      'imageUrl': staff['imageUrl'],
      'avatarBytes': staff['avatarBytes'],
      'initials': staff['initials'] ??
          (staff['name'] != null && (staff['name'] as String).isNotEmpty
              ? (staff['name'] as String).substring(0, 1).toUpperCase()
              : 'S'),
      'storeName': staff['storeName'] ?? activeStore,
    };

    // 1. Update in-memory roster immediately and trigger notifiers
    final currentPagi = List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value);
    final currentSore = List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value);

    if (shiftTab == 0) {
      currentPagi.removeWhere((item) => item['name'] == staffMap['name']);
      currentPagi.add(staffMap);
      shiftRosterPagiNotifier.value = currentPagi;
    } else {
      currentSore.removeWhere((item) => item['name'] == staffMap['name']);
      currentSore.add(staffMap);
      shiftRosterSoreNotifier.value = currentSore;
    }

    // 2. Update calendar history immediately and trigger notifier
    final history = Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
    final existingData = history[dateKey] ?? {
      'pagi': List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value),
      'sore': List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value),
    };
    final datePagi = List<Map<String, dynamic>>.from(existingData['pagi'] ?? currentPagi);
    final dateSore = List<Map<String, dynamic>>.from(existingData['sore'] ?? currentSore);

    if (shiftTab == 0) {
      datePagi.removeWhere((item) => item['name'] == staffMap['name']);
      datePagi.add(staffMap);
    } else {
      dateSore.removeWhere((item) => item['name'] == staffMap['name']);
      dateSore.add(staffMap);
    }

    history[dateKey] = {'pagi': datePagi, 'sore': dateSore};
    shiftCalendarHistoryNotifier.value = history;

    // 3. Persist to Firestore / SQLite
    try {
      final model = ShiftModel(
        id: staffMap['id'] as int?,
        staffName: staffMap['name'] as String,
        role: staffMap['role'] as String,
        shiftType: shiftType,
        dateKey: dateKey,
        status: staffMap['status'] as String,
        checkInTime: staffMap['time'] as String,
        storeName: staffMap['storeName'] as String,
        avatarUrl: staffMap['imageUrl'] as String?,
        initials: staffMap['initials'] as String?,
      );
      await DataBaseHelper().insertShift(model);
    } catch (e) {
      debugPrint('Error inserting shift to database: $e');
    }
  }

  Future<void> editStaffInRoster(
    int shiftTab,
    int index,
    Map<String, dynamic> updatedStaff, {
    DateTime? activeDate,
  }) async {
    final targetDate = activeDate ?? _currentActiveDate;
    final dateKey = formatDateKey(targetDate);
    final shiftType = shiftTab == 0 ? 'Pagi' : 'Sore';
    final currentList = shiftTab == 0 ? List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value) : List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value);

    if (index >= 0 && index < currentList.length) {
      final oldItem = currentList[index];
      final mergedItem = {
        ...oldItem,
        ...updatedStaff,
        'storeName': updatedStaff['storeName'] ?? oldItem['storeName'] ?? (userDataNotifier.value['storeName'] ?? 'Bella Cafe'),
      };
      currentList[index] = mergedItem;

      if (shiftTab == 0) {
        shiftRosterPagiNotifier.value = currentList;
      } else {
        shiftRosterSoreNotifier.value = currentList;
      }

      final history = Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
      final existingData = history[dateKey] ?? {'pagi': currentList, 'sore': currentList};
      if (shiftTab == 0) {
        history[dateKey] = {...existingData, 'pagi': currentList};
      } else {
        history[dateKey] = {...existingData, 'sore': currentList};
      }
      shiftCalendarHistoryNotifier.value = history;

      final shiftId = oldItem['id'] as int?;
      final model = ShiftModel(
        id: shiftId,
        staffName: mergedItem['name'] as String? ?? oldItem['name'],
        role: mergedItem['role'] as String? ?? oldItem['role'],
        shiftType: shiftType,
        dateKey: dateKey,
        status: mergedItem['status'] as String? ?? oldItem['status'],
        checkInTime: mergedItem['time'] as String? ?? oldItem['time'],
        storeName: mergedItem['storeName'] as String,
        avatarUrl: mergedItem['imageUrl'] as String?,
        initials: mergedItem['initials'] as String?,
      );

      if (shiftId != null) {
        try {
          await DataBaseHelper().updateShift(model);
        } catch (_) {}
      }
    }
  }

  Future<void> deleteStaffFromRoster(
    int shiftTab,
    int index, {
    DateTime? activeDate,
  }) async {
    final targetDate = activeDate ?? _currentActiveDate;
    final dateKey = formatDateKey(targetDate);
    final currentList = shiftTab == 0 ? List<Map<String, dynamic>>.from(shiftRosterPagiNotifier.value) : List<Map<String, dynamic>>.from(shiftRosterSoreNotifier.value);

    if (index >= 0 && index < currentList.length) {
      final item = currentList.removeAt(index);

      if (shiftTab == 0) {
        shiftRosterPagiNotifier.value = currentList;
      } else {
        shiftRosterSoreNotifier.value = currentList;
      }

      final history = Map<String, Map<String, dynamic>>.from(shiftCalendarHistoryNotifier.value);
      final existingData = history[dateKey] ?? {'pagi': currentList, 'sore': currentList};
      if (shiftTab == 0) {
        history[dateKey] = {...existingData, 'pagi': currentList};
      } else {
        history[dateKey] = {...existingData, 'sore': currentList};
      }
      shiftCalendarHistoryNotifier.value = history;

      final shiftId = item['id'] as int?;
      if (shiftId != null) {
        try {
          await DataBaseHelper().deleteShift(shiftId);
        } catch (_) {}
      }
    }
  }

  Future<void> addCafeStaff(Map<String, dynamic> staff) async {
    final currentStaff = List<Map<String, dynamic>>.from(cafeStaffListNotifier.value);
    currentStaff.removeWhere((s) => s['name'] == staff['name']);
    currentStaff.add(staff);
    cafeStaffListNotifier.value = currentStaff;

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

    try {
      await DataBaseHelper().insertStaff(model);
    } catch (_) {}
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

    // 1. Persist to active_session in Firestore
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

    // 2. Update users collection in Firestore
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

    // 3. Sync to Firebase Auth & user doc if currentUser is logged in
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final profileName = current['accountName'] ?? current['cashierName'];
        if (profileName != null && profileName.toString().isNotEmpty) {
          await user.updateDisplayName(profileName.toString());
        }

        await _firestore.collection('users').doc(user.uid).set({
          'nama': profileName,
          'email': current['email'],
          'cashierId': current['cashierId'],
          'role': current['accountRole'] ?? current['cashierRole'],
          'nomor_hp': current['phone'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore profile sync info: $e');
    }
  }

  final Set<String> _deletedStoreNames = {};

  bool isStoreDeleted(String storeName) =>
      _deletedStoreNames.contains(storeName.trim().toLowerCase());

  Future<void> reloadStoreList() async {
    try {
      final stores = await DataBaseHelper().getAllStores();
      final names = stores
          .map((s) => s.name.trim())
          .where((name) => name.isNotEmpty && !_deletedStoreNames.contains(name.toLowerCase()))
          .toList();
      final currentStore = (userDataNotifier.value['storeName'] as String?)?.trim();
      if (currentStore != null &&
          currentStore.isNotEmpty &&
          !_deletedStoreNames.contains(currentStore.toLowerCase()) &&
          !names.contains(currentStore)) {
        names.insert(0, currentStore);
      }
      if (names.isEmpty && _deletedStoreNames.isEmpty) {
        names.addAll([
          'Bella Cafe',
          'BGA Co. - Central Perk',
          'BGA Co. - Downtown Latte',
          'BGA Co. - Westside Brew',
        ]);
      }
      final uniqueNames = names
          .where((name) => !_deletedStoreNames.contains(name.toLowerCase()))
          .toSet()
          .toList();
      storeListNotifier.value = uniqueNames;
    } catch (e) {
      debugPrint('Error loading store list from Firebase: $e');
    }
  }

  void addStoreName(String storeName) {
    final trimmed = storeName.trim();
    if (trimmed.isEmpty) return;
    _deletedStoreNames.remove(trimmed.toLowerCase());
    final current = List<String>.from(storeListNotifier.value);
    if (!current.contains(trimmed)) {
      current.add(trimmed);
      storeListNotifier.value = current;
    }
  }

  Future<void> removeStore(String storeName, {int? id}) async {
    final trimmed = storeName.trim();
    if (trimmed.isEmpty) return;
    _deletedStoreNames.add(trimmed.toLowerCase());

    if (id != null) {
      await DataBaseHelper().deleteStore(id);
    }
    await DataBaseHelper().deleteStoreByName(trimmed);

    final current = List<String>.from(storeListNotifier.value);
    current.removeWhere((item) => item.trim().toLowerCase() == trimmed.toLowerCase());
    storeListNotifier.value = current;

    // If the active store is the one being deleted, switch to another available store
    final activeStore = (userDataNotifier.value['storeName'] as String?)?.trim();
    if (activeStore != null && activeStore.toLowerCase() == trimmed.toLowerCase()) {
      if (current.isNotEmpty) {
        await updateUserData({
          'storeName': current.first,
          'location': 'Jakarta',
        });
      } else {
        await updateUserData({
          'storeName': '',
          'location': '',
        });
      }
    }

    await reloadStoreList();
  }

  void dispose() {
    _staffSubscription?.cancel();
    _shiftsSubscription?.cancel();
    _storesSubscription?.cancel();
  }
}
