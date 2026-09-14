import 'dart:async';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/database/database_helper.dart';
import 'package:cashier/CASHIER/models/store_model.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/utils/user_data_store.dart';
import 'package:cashier/CASHIER/views/Home/Shift/add_staff_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffShiftScreen extends StatefulWidget {
  final String activeShift;

  const StaffShiftScreen({
    super.key,
    this.activeShift = 'Afternoon Shift: 15:00 - 23:00',
  });

  @override
  State<StaffShiftScreen> createState() => _StaffShiftScreenState();
}

class _StaffShiftScreenState extends State<StaffShiftScreen> {
  int _selectedTabIndex = 0; // 0: CALENDAR, 1: MANAJEMEN SHIFT
  int _selectedShiftTab = 0; // 0: Shift Pagi, 1: Shift Sore

  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _storesSubscription;
  StreamSubscription<QuerySnapshot>? _shiftsSubscription;
  StreamSubscription<QuerySnapshot>? _staffSubscription;

  // Dynamic Color Tokens linked to AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorPrimaryContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF3B3835)
      : const Color(0xFF5D4037);
  Color get colorOnPrimaryContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFFF5EFEA)
      : const Color(0xFFD4ADA1);
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurface => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorSurfaceContainerHigh => AppTheme.instance.surfaceContainer;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorTertiary => AppTheme.instance.isDarkMode
      ? const Color(0xFFF0BD8B)
      : const Color(0xFF2E3218);
  Color get colorSurfaceDim => AppTheme.instance.surfaceContainerLow;
  Color get colorSecondaryContainer => AppTheme.instance.secondaryContainer;
  Color get colorOnSecondaryContainer => AppTheme.instance.onSecondaryContainer;

  // Status Badge Colors
  Color get colorGreenBg => AppTheme.instance.isDarkMode
      ? const Color(0xFF1B4D2E)
      : const Color(0xFFDCFCE7);
  Color get colorGreenText => AppTheme.instance.isDarkMode
      ? const Color(0xFF86EFAC)
      : const Color(0xFF166534);
  Color get colorErrorContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF501010)
      : const Color(0xFFFFDAD6);
  Color get colorOnErrorContainer => const Color(0xFF93000A);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _focusedMonth = DateTime(now.year, now.month, 1);
    UserDataStore.instance.initFromFirebase();
    UserDataStore.instance.reloadShiftsForDate(now);
    _listenToFirebaseRealtime();

    UserDataStore.instance.shiftRosterPagiNotifier.addListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.shiftRosterSoreNotifier.addListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.cafeStaffListNotifier.addListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.shiftCalendarHistoryNotifier.addListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.userDataNotifier.addListener(
      _onUserDataStoreChanged,
    );
  }

  void _listenToFirebaseRealtime() {
    try {
      _storesSubscription = _firestore.collection('stores').snapshots().listen((
        _,
      ) {
        UserDataStore.instance.reloadStoreList();
        if (mounted) setState(() {});
      });
      _shiftsSubscription = _firestore.collection('shifts').snapshots().listen((
        _,
      ) {
        UserDataStore.instance.reloadShiftsForDate(_selectedDate);
        if (mounted) setState(() {});
      });
      _staffSubscription = _firestore.collection('staff').snapshots().listen((
        _,
      ) {
        UserDataStore.instance.reloadStaffList();
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint(
        'Error attaching Firebase listeners to staff shift screen: $e',
      );
    }
  }

  @override
  void dispose() {
    _storesSubscription?.cancel();
    _shiftsSubscription?.cancel();
    _staffSubscription?.cancel();
    UserDataStore.instance.shiftRosterPagiNotifier.removeListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.shiftRosterSoreNotifier.removeListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.cafeStaffListNotifier.removeListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.shiftCalendarHistoryNotifier.removeListener(
      _onUserDataStoreChanged,
    );
    UserDataStore.instance.userDataNotifier.removeListener(
      _onUserDataStoreChanged,
    );
    super.dispose();
  }

  void _onUserDataStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  int _getDaysInMonth(DateTime monthDate) {
    return DateTime(monthDate.year, monthDate.month + 1, 0).day;
  }

  int _getFirstWeekdayOffset(DateTime monthDate) {
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    return firstDay.weekday - 1; // 0 for Monday, 6 for Sunday
  }

  Future<void> _selectDateViaPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih Tanggal, Bulan, dan Tahun Shift',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorPrimary,
              onPrimary: Colors.white,
              surface: colorSurfaceContainerLowest,
              onSurface: colorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _focusedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  int _calendarShiftFilter = 0; // 0: Semua, 1: Shift Pagi, 2: Shift Sore

  // Dynamic Data for Calendar View from UserDataStore history
  List<Map<String, dynamic>> get _staffCalendarList =>
      UserDataStore.instance.getStaffWhoWorkedOnDate(
        _selectedDate,
        shiftFilter: _calendarShiftFilter,
      );

  // Persistent Data from UserDataStore for the active selected date
  List<Map<String, dynamic>> get _shiftRosterPagi =>
      UserDataStore.instance.getRosterPagiForDate(_selectedDate);
  List<Map<String, dynamic>> get _shiftRosterSore =>
      UserDataStore.instance.getRosterSoreForDate(_selectedDate);

  String _formatStaffShiftTime(dynamic shiftVal, int tabIndex) {
    if (shiftVal == null || shiftVal.toString().isEmpty) {
      return tabIndex == 0 ? '07:00 - 15:00 WIB' : '15:00 - 23:00 WIB';
    }
    final s = shiftVal.toString().toLowerCase();
    if (s == 'pagi') return '07:00 - 15:00 WIB';
    if (s == 'middle') return '11:00 - 19:00 WIB';
    if (s == 'sore') return '14:30 - 22:30 WIB';
    if (!s.contains('wib')) return '$shiftVal WIB';
    return shiftVal.toString();
  }

  Future<void> _showAddStoreDialog() async {
    final nameC = TextEditingController();
    final locationC = TextEditingController();
    String selectedConcept = 'Coffee Shop & Cafe';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorOutlineVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorSecondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: colorSecondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tambah Toko / Cabang',
                                  style: GoogleFonts.sourceSerif4(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: colorPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Daftarkan cabang atau outlet baru ke kasir',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Nama Toko Field
                      Text(
                        'Nama Toko / Outlet',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameC,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: colorPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Kingkong Cafe - Branch 2',
                          hintStyle: GoogleFonts.workSans(
                            fontSize: 13,
                            color: colorOnSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.store_rounded,
                            size: 20,
                            color: colorSecondary,
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorSecondary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama toko wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Lokasi Kota Field
                      Text(
                        'Lokasi / Kota Cabang',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: locationC,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: colorPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Jakarta Selatan / Bandung',
                          hintStyle: GoogleFonts.workSans(
                            fontSize: 13,
                            color: colorOnSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.location_on_rounded,
                            size: 20,
                            color: colorSecondary,
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorSecondary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Lokasi cabang wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Konsep Toko Dropdown
                      Text(
                        'Konsep / Tipe Outlet',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedConcept,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorSecondary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items:
                            [
                              'Coffee Shop & Cafe',
                              'Artisan Roastery',
                              'Express Kiosk',
                              'Bakery & Pastry',
                              'Resto & Eatery',
                            ].map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    color: colorPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedConcept = val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons (Batal & Simpan)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: colorOutline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.workSans(
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final storeName = nameC.text.trim();
                                  final location = locationC.text.trim();

                                  try {
                                    final newStore = StoreModel(
                                      name: storeName,
                                      location: location,
                                      defaultShift: 'Pagi',
                                    );
                                    await DataBaseHelper().insertStore(
                                      newStore,
                                    );

                                    // Simpan ke collection 'stores' Firestore
                                    final docId = storeName
                                        .toLowerCase()
                                        .replaceAll(RegExp(r'\s+'), '_');
                                    await _firestore
                                        .collection('stores')
                                        .doc(docId)
                                        .set({
                                          'name': storeName,
                                          'location': location,
                                          'defaultShift': 'Pagi',
                                          'updatedAt':
                                              FieldValue.serverTimestamp(),
                                        }, SetOptions(merge: true));

                                    // Update Firestore user document
                                    final currentUser = _auth.currentUser;
                                    if (currentUser != null) {
                                      await _firestore
                                          .collection('users')
                                          .doc(currentUser.uid)
                                          .set({
                                            'storeName': storeName,
                                            'location': location,
                                            'lastActive':
                                                FieldValue.serverTimestamp(),
                                          }, SetOptions(merge: true));
                                    }
                                  } catch (e) {
                                    debugPrint(
                                      'Error inserting store to Firestore: $e',
                                    );
                                  }

                                  UserDataStore.instance.addStoreName(
                                    storeName,
                                  );
                                  await UserDataStore.instance
                                      .reloadStoreList();

                                  await UserDataStore.instance.updateUserData({
                                    'storeName': storeName,
                                    'location': location,
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Toko "$storeName" ($location) berhasil ditambahkan & diaktifkan!',
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: colorSecondary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorSecondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Simpan Toko',
                                style: GoogleFonts.workSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteStoreDialog(StoreModel store) {
    final displayName = store.name.trim().isNotEmpty
        ? store.name.trim()
        : (store.location.isNotEmpty
              ? 'Toko (${store.location})'
              : 'Toko Cabang');
    final displayLocation = store.location.trim().isNotEmpty
        ? store.location
        : 'Indonesia';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colorSurfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hapus Toko?',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "$displayName" ($displayLocation) dari daftar toko?',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: colorOnSurfaceVariant,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colorOutlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.bold,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogCtx);
                      try {
                        if (store.docId != null && store.docId!.isNotEmpty) {
                          try {
                            await _firestore
                                .collection('stores')
                                .doc(store.docId)
                                .delete();
                          } catch (_) {}
                        }
                        if (store.name.trim().isNotEmpty) {
                          final snapshot = await _firestore
                              .collection('stores')
                              .where('name', isEqualTo: store.name.trim())
                              .get();
                          for (final doc in snapshot.docs) {
                            await doc.reference.delete();
                          }
                          final slugDoc = store.name
                              .trim()
                              .toLowerCase()
                              .replaceAll(RegExp(r'\s+'), '_');
                          try {
                            await _firestore
                                .collection('stores')
                                .doc(slugDoc)
                                .delete();
                          } catch (_) {}
                        }
                        if (store.id != null) {
                          try {
                            await _firestore
                                .collection('stores')
                                .doc('store_${store.id}')
                                .delete();
                          } catch (_) {}
                          final idSnapshot = await _firestore
                              .collection('stores')
                              .where('id', isEqualTo: store.id)
                              .get();
                          for (final doc in idSnapshot.docs) {
                            await doc.reference.delete();
                          }
                        }
                      } catch (e) {
                        debugPrint('Error deleting store from Firestore: $e');
                      }

                      await UserDataStore.instance.removeStore(
                        store.name,
                        id: store.id,
                        docId: store.docId,
                      );

                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Toko "$displayName" berhasil dihapus! 🗑️',
                              style: GoogleFonts.workSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Hapus',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarFilterChip(String label, int filterIndex) {
    final isSelected = _calendarShiftFilter == filterIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _calendarShiftFilter = filterIndex;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorSecondary : colorSurfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorSecondary
                : colorOutlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : colorPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffAvatarBadge(
    Map<String, dynamic> staff, {
    double size = 46,
  }) {
    final name = staff['name']?.toString() ?? 'Staf';
    String inits = staff['initials']?.toString() ?? '';
    if (inits.isEmpty || inits == 'ST') {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        inits = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        inits = parts[0][0].toUpperCase();
      } else {
        inits = 'ST';
      }
    }

    final colors = [
      [const Color(0xFFD97706), const Color(0xFF92400E)], // Amber Caramel
      [const Color(0xFF8D6E63), const Color(0xFF4E342E)], // Espresso Cocoa
      [const Color(0xFF059669), const Color(0xFF065F46)], // Emerald Sage
      [const Color(0xFF0284C7), const Color(0xFF075985)], // Ocean Slate
      [const Color(0xFFC026D3), const Color(0xFF86198F)], // Berry Violet
      [const Color(0xFFEA580C), const Color(0xFF9A3412)], // Terracotta
      [const Color(0xFF475569), const Color(0xFF1E293B)], // Dark Slate
    ];
    final colorPair = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorPair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withValues(alpha: 0.28),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          inits,
          style: GoogleFonts.sourceSerif4(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _showAddStaffDialog() async {
    final newStaff =
        await context.push(const AddStaffScreen()) as Map<String, dynamic>?;
    if (newStaff != null) {
      int targetTab = _selectedShiftTab;
      final s = newStaff['shiftTime']?.toString().toLowerCase() ?? '';
      if (s == 'pagi') {
        targetTab = 0;
      } else if (s == 'sore' || s == 'middle') {
        targetTab = 1;
      }

      await UserDataStore.instance.addStaffToRoster(
        targetTab,
        newStaff,
        activeDate: _selectedDate,
      );
      await UserDataStore.instance.addCafeStaff(newStaff);

      if (mounted) {
        setState(() {
          _selectedShiftTab = targetTab;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Staf ${newStaff['name']} berhasil ditambahkan ke ${targetTab == 0 ? "Shift Pagi" : "Shift Sore"} & Tersinkron ke Kalender! 🎉',
            ),
            backgroundColor: colorSecondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditStaffDialog(
    Map<String, dynamic> staff,
    int staffIndex,
    int shiftTab,
  ) {
    final nameController = TextEditingController(text: staff['name'] ?? '');
    final roleController = TextEditingController(
      text: staff['role'] ?? 'Barista',
    );
    final shiftTimeController = TextEditingController(
      text:
          staff['shiftTime'] ??
          (shiftTab == 0 ? '07:00 - 15:00' : '15:00 - 23:00'),
    );
    final timeController = TextEditingController(
      text: staff['time'] ?? 'In: 07:00',
    );
    String selectedStatus = staff['status'] ?? 'Hadir';
    String selectedStore =
        staff['storeName'] as String? ??
        (UserDataStore.instance.userDataNotifier.value['storeName']
                as String? ??
            'Bella Cafe');
    String? errorMessage;

    final List<String> rolePresets = [
      'Head Barista',
      'Barista',
      'Kasir',
      'Kasir Utama',
      'Pâtissier',
      'Pelayan',
      'Runner',
      'Kitchen Staff',
      'Supervisor',
    ];

    final List<String> statusPresets = [
      'Hadir',
      'Istirahat',
      'Belum Hadir',
      'Izin',
      'Libur',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: colorSecondary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.edit_note_rounded,
                                  size: 32,
                                  color: colorSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Edit Staf Bertugas',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perbarui data staf dan status kehadiran di shift.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFDC2626),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: const Color(0xFF991B1B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Nama Staf
                      Text(
                        'Nama Staf',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: colorPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nama lengkap staf',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: colorPrimary,
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Posisi / Role
                      Text(
                        'Posisi / Jabatan',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: roleController,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: colorPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Barista',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            color: colorPrimary,
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Role Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: rolePresets.map((r) {
                          final isSelected = roleController.text == r;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                roleController.text = r;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorSecondary
                                    : colorSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? colorSecondary
                                      : colorOutlineVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                              child: Text(
                                r,
                                style: GoogleFonts.workSans(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : colorPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Toko / Outlet Bertugas Dropdown
                      Text(
                        'Toko / Outlet Bertugas',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ValueListenableBuilder<List<String>>(
                        valueListenable:
                            UserDataStore.instance.storeListNotifier,
                        builder: (context, stores, _) {
                          final storeOptions = List<String>.from(stores);
                          if (!storeOptions.contains(selectedStore) &&
                              selectedStore.isNotEmpty) {
                            storeOptions.insert(0, selectedStore);
                          }
                          final activeValue =
                              storeOptions.contains(selectedStore)
                              ? selectedStore
                              : (storeOptions.isNotEmpty
                                    ? storeOptions.first
                                    : null);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: colorSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: activeValue,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: colorPrimary,
                                ),
                                items: storeOptions.map((st) {
                                  return DropdownMenuItem<String>(
                                    value: st,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.storefront_outlined,
                                          size: 18,
                                          color: colorSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            st,
                                            style: GoogleFonts.workSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: colorPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedStore = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Status Kehadiran Dropdown
                      Text(
                        'Status Kehadiran',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: colorPrimary,
                            ),
                            items: statusPresets.map((st) {
                              return DropdownMenuItem<String>(
                                value: st,
                                child: Text(
                                  st,
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    color: colorPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedStatus = val;
                                  if (val == 'Hadir') {
                                    timeController.text = shiftTab == 0
                                        ? 'In: 06:45'
                                        : 'In: 14:50';
                                  } else if (val == 'Istirahat') {
                                    timeController.text = '12:00 - 13:00';
                                  } else if (val == 'Belum Hadir') {
                                    timeController.text = '-';
                                  } else {
                                    timeController.text = 'Off';
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Waktu Masuk (In Time)
                      Text(
                        'Waktu Masuk / Keterangan',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: timeController,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: colorPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: In: 06:50 atau 12:00 - 13:00',
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: colorPrimary,
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: colorOutlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w600,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final role = roleController.text.trim();
                          final shiftTime = shiftTimeController.text.trim();
                          final time = timeController.text.trim();

                          if (name.isEmpty) {
                            setDialogState(() {
                              errorMessage = 'Nama staf tidak boleh kosong!';
                            });
                            return;
                          }
                          if (role.isEmpty) {
                            setDialogState(() {
                              errorMessage = 'Posisi tidak boleh kosong!';
                            });
                            return;
                          }

                          // Initials
                          final nameParts = name.split(' ');
                          String inits = '';
                          if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
                            inits += nameParts[0][0];
                          }
                          if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
                            inits += nameParts[1][0];
                          }
                          if (inits.isEmpty) inits = 'ST';
                          inits = inits.toUpperCase();

                          final updatedStaff = {
                            'name': name,
                            'role': role,
                            'status': selectedStatus,
                            'storeName': selectedStore,
                            'shiftTime': shiftTime.isNotEmpty
                                ? shiftTime
                                : (shiftTab == 0
                                      ? '07:00 - 15:00'
                                      : '15:00 - 23:00'),
                            'time': time.isNotEmpty ? time : '-',
                            'imageUrl': staff['imageUrl'],
                            'initials': inits,
                          };

                          setState(() {
                            UserDataStore.instance.editStaffInRoster(
                              shiftTab,
                              staffIndex,
                              updatedStaff,
                              activeDate: _selectedDate,
                            );
                          });

                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Data staf $name berhasil diperbarui! ✏️',
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: colorSecondary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: colorSecondary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteStaffDialog(
    Map<String, dynamic> staff,
    int staffIndex,
    int shiftTab,
  ) {
    final shiftName = shiftTab == 0 ? 'Shift Pagi' : 'Shift Sore';
    final staffName = staff['name'] ?? 'Staf';
    final staffRole = staff['role'] ?? 'Karyawan';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colorSurfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hapus Staf?',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus $staffName ($staffRole) dari daftar tugas $shiftName?',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: colorOnSurfaceVariant,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colorOutlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w600,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        UserDataStore.instance.deleteStaffFromRoster(
                          shiftTab,
                          staffIndex,
                          activeDate: _selectedDate,
                        );
                      });
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Staf $staffName berhasil dihapus dari $shiftName! 🗑️',
                            style: GoogleFonts.workSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Hapus',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;
    final monthFormat = DateFormat('MMMM yyyy', 'id_ID');
    final dateFormatFull = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final totalDays = _getDaysInMonth(_focusedMonth);
    final offset = _getFirstWeekdayOffset(_focusedMonth);
    final totalGridItems = totalDays + offset;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: colorBackground,
          appBar: AppBar(
            backgroundColor: colorSurface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Shift',
              style: GoogleFonts.sourceSerif4(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colorPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_month_outlined, color: colorPrimary),
                tooltip: 'Pilih Tanggal & Bulan',
                onPressed: _selectDateViaPicker,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Top Tabs Navigation (CALENDAR vs MANAJEMEN SHIFT vs DAFTAR TOKO)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorOutlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: _selectedTabIndex == 0
                                        ? Border(
                                            bottom: BorderSide(
                                              color: colorSecondary,
                                              width: 2.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'CALENDAR',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.workSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: _selectedTabIndex == 0
                                          ? colorSecondary
                                          : colorOnSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: _selectedTabIndex == 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: colorSecondary,
                                              width: 2.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'MANAJEMEN SHIFT',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.workSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: _selectedTabIndex == 1
                                          ? colorSecondary
                                          : colorOnSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: _selectedTabIndex == 2
                                        ? Border(
                                            bottom: BorderSide(
                                              color: colorSecondary,
                                              width: 2.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'DAFTAR TOKO',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.workSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: _selectedTabIndex == 2
                                          ? colorSecondary
                                          : colorOnSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TAB 1: CALENDAR VIEW
                      if (_selectedTabIndex == 0) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: colorSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(68, 42, 34, 0.12),
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectDateViaPicker,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  monthFormat
                                                      .format(_focusedMonth)
                                                      .toUpperCase(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.0,
                                                    color: colorSecondary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                size: 18,
                                                color: colorSecondary,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dateFormatFull.format(
                                              _selectedDate,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.sourceSerif4(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: _previousMonth,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colorOutlineVariant,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.chevron_left,
                                            size: 18,
                                            color: colorPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: _nextMonth,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colorOutlineVariant,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.chevron_right,
                                            size: 18,
                                            color: colorPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children:
                                    [
                                          'SEN',
                                          'SEL',
                                          'RAB',
                                          'KAM',
                                          'JUM',
                                          'SAB',
                                          'MING',
                                        ]
                                        .map(
                                          (day) => Expanded(
                                            child: Text(
                                              day,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.workSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: colorOutline,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 12),

                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: totalGridItems,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 1.0,
                                    ),
                                itemBuilder: (context, index) {
                                  if (index < offset) {
                                    return const SizedBox.shrink();
                                  }
                                  final dayNumber = index - offset + 1;
                                  final dateOfCell = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month,
                                    dayNumber,
                                  );
                                  final isSelected =
                                      dateOfCell.year == _selectedDate.year &&
                                      dateOfCell.month == _selectedDate.month &&
                                      dateOfCell.day == _selectedDate.day;

                                  final isToday =
                                      dateOfCell.year == 2026 &&
                                      dateOfCell.month == 8 &&
                                      dateOfCell.day == 14;

                                  final hasData = UserDataStore.instance
                                      .hasRecordedShiftOnDate(dateOfCell);

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = dateOfCell;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorPrimary
                                            : (isToday
                                                  ? colorSecondaryContainer
                                                        .withValues(alpha: 0.5)
                                                  : Colors.transparent),
                                        borderRadius: BorderRadius.circular(10),
                                        border: isSelected
                                            ? null
                                            : (isToday
                                                  ? Border.all(
                                                      color: colorSecondary,
                                                      width: 1.5,
                                                    )
                                                  : null),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$dayNumber',
                                            style: GoogleFonts.workSans(
                                              fontSize: 14,
                                              fontWeight: isSelected || isToday
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : colorPrimary,
                                            ),
                                          ),
                                          if (hasData)
                                            Container(
                                              width: 4.5,
                                              height: 4.5,
                                              margin: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? Colors.white
                                                    : colorSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0x1A442A22),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.event_available_rounded,
                                      size: 18,
                                      color: colorSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Jadwal Shift • Terpilih: ${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate)}',
                                        style: GoogleFonts.workSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorOnSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Section Header: Who is on Shift
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Who is on Shift',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat(
                                      'EEEE, d MMMM yyyy',
                                      'id_ID',
                                    ).format(_selectedDate),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.workSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: colorOnSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorSecondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_staffCalendarList.length} Staf Bertugas',
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Shift Filter Chips (Semua, Shift Pagi, Shift Sore)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCalendarFilterChip(
                                'Semua (${UserDataStore.instance.getStaffWhoWorkedOnDate(_selectedDate, shiftFilter: 0).length})',
                                0,
                              ),
                              const SizedBox(width: 8),
                              _buildCalendarFilterChip(
                                'Shift Pagi (${UserDataStore.instance.getStaffWhoWorkedOnDate(_selectedDate, shiftFilter: 1).length})',
                                1,
                              ),
                              const SizedBox(width: 8),
                              _buildCalendarFilterChip(
                                'Shift Sore (${UserDataStore.instance.getStaffWhoWorkedOnDate(_selectedDate, shiftFilter: 2).length})',
                                2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Staff List for Selected Date
                        if (_staffCalendarList.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: colorSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorOutlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy_rounded,
                                  size: 40,
                                  color: colorOnSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada catatan shift untuk tanggal ini',
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      UserDataStore.instance
                                          .syncActiveRosterToDate(
                                            _selectedDate,
                                          );
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Jadwal staf aktif berhasil disimpan ke ${DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate)}!',
                                          style: GoogleFonts.workSans(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: colorSecondary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.sync_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Salin Shift Aktif ke Tanggal Ini',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorSecondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: _staffCalendarList.map((staff) {
                              final status =
                                  staff['status']?.toString() ?? 'Hadir';
                              final isHadir =
                                  status == 'Hadir' || status == 'ON DUTY';
                              final isRest = status == 'Istirahat';
                              final isAbsent = status == 'Belum Hadir';

                              Color statusBg = colorGreenBg;
                              Color statusText = colorGreenText;
                              if (isRest) {
                                statusBg = const Color(0xFFFFEDD5);
                                statusText = const Color(0xFFC2410C);
                              } else if (isAbsent) {
                                statusBg = colorSurfaceContainerHigh;
                                statusText = colorOnSurfaceVariant;
                              } else if (!isHadir) {
                                statusBg = const Color(0xFFE0F2FE);
                                statusText = const Color(0xFF0369A1);
                              }

                              final shiftName =
                                  staff['shiftName']?.toString() ??
                                  'Shift Kerja';
                              final shiftBadgeColor =
                                  staff['shiftBadgeColor'] as Color? ??
                                  const Color(0xFFDCFCE7);
                              final shiftTextColor =
                                  staff['shiftTextColor'] as Color? ??
                                  const Color(0xFF166534);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colorSurfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isRest
                                        ? const Color(
                                            0xFFEA580C,
                                          ).withValues(alpha: 0.3)
                                        : colorOutlineVariant.withValues(
                                            alpha: 0.35,
                                          ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(68, 42, 34, 0.04),
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar Badge with clear gradient & bold white initials
                                    _buildStaffAvatarBadge(staff, size: 48),
                                    const SizedBox(width: 14),

                                    // Name, Role & Shift Badge
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff['name'] ?? 'Staf',
                                            style: GoogleFonts.sourceSerif4(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Text(
                                                staff['role'] ?? 'Karyawan',
                                                style: GoogleFonts.workSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: colorOnSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: shiftBadgeColor,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  shiftName,
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: shiftTextColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (staff['time'] != null &&
                                              staff['time'] != '-') ...[
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Icon(
                                                  isRest
                                                      ? Icons
                                                            .free_breakfast_outlined
                                                      : Icons
                                                            .access_time_rounded,
                                                  size: 13,
                                                  color: isRest
                                                      ? const Color(0xFFC2410C)
                                                      : colorSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  staff['time'],
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: isRest
                                                        ? const Color(
                                                            0xFFC2410C,
                                                          )
                                                        : colorSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Status Indicator Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: statusText,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            status.toUpperCase(),
                                            style: GoogleFonts.workSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: statusText,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ] else if (_selectedTabIndex == 1) ...[
                        // TAB 2: MANAJEMEN SHIFT VIEW
                        // Header Title & Description
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manajemen Shift',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jadwal tugas harian dan status kehadiran staf toko.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 13,
                                      color: colorOnSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card Tanggal Shift
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colorSecondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorSecondary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: colorSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tanggal: ${dateFormatFull.format(_selectedDate)}',
                                  style: GoogleFonts.workSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: colorPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorGreenBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Tersinkron ke Kalender',
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorGreenText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sub-Tab Switcher: SHIFT PAGI vs SHIFT SORE
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorOutlineVariant,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selectedShiftTab = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: _selectedShiftTab == 0
                                          ? Border(
                                              bottom: BorderSide(
                                                color: colorSecondary,
                                                width: 2.5,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Text(
                                      'SHIFT PAGI',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.workSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                        color: _selectedShiftTab == 0
                                            ? colorSecondary
                                            : colorOnSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selectedShiftTab = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: _selectedShiftTab == 1
                                          ? Border(
                                              bottom: BorderSide(
                                                color: colorSecondary,
                                                width: 2.5,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Text(
                                      'SHIFT SORE',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.workSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                        color: _selectedShiftTab == 1
                                            ? colorSecondary
                                            : colorOnSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Card Info Jadwal & Counter Staf Hadir
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colorSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              left: BorderSide(color: colorSecondary, width: 5),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(68, 42, 34, 0.08),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedShiftTab == 0
                                        ? 'Jadwal Pagi'
                                        : 'Jadwal Sore',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: colorOnSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedShiftTab == 0
                                            ? '07:00 - 15:00 WIB'
                                            : '15:00 - 23:00 WIB',
                                        style: GoogleFonts.workSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colorOnSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: colorSurfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colorOutlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'STAF HADIR',
                                      style: GoogleFonts.workSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: colorOnSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Builder(
                                      builder: (context) {
                                        final list = _selectedShiftTab == 0
                                            ? _shiftRosterPagi
                                            : _shiftRosterSore;
                                        final hadirCount = list
                                            .where(
                                              (s) =>
                                                  (s['status'] as String? ??
                                                      '') ==
                                                  'Hadir',
                                            )
                                            .length;
                                        return Text(
                                          '$hadirCount/${list.length}',
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: colorPrimary,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Title: Daftar Staf Bertugas + Button + STAF
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daftar Staf Bertugas',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddStaffDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorSecondary,
                                foregroundColor: Colors.white,
                                elevation: 1.5,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                '+ STAF',
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Staff Roster Cards List
                        if ((_selectedShiftTab == 0
                                ? _shiftRosterPagi
                                : _shiftRosterSore)
                            .isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 36,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: colorSurfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorOutlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 48,
                                  color: colorOnSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada staf di shift ini',
                                  style: GoogleFonts.workSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colorPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Klik tombol "+ STAF" di atas untuk menambahkan jadwal tugas staf.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(
                            (_selectedShiftTab == 0
                                    ? _shiftRosterPagi
                                    : _shiftRosterSore)
                                .length,
                            (index) {
                              final currentList = _selectedShiftTab == 0
                                  ? _shiftRosterPagi
                                  : _shiftRosterSore;
                              final staff = currentList[index];
                              final status =
                                  staff['status'] as String? ?? 'Hadir';

                              Color badgeBgColor = colorGreenBg;
                              Color badgeTextColor = colorGreenText;
                              if (status == 'Istirahat') {
                                badgeBgColor = const Color(0xFFFEF3C7);
                                badgeTextColor = const Color(0xFF92400E);
                              } else if (status == 'Belum Hadir') {
                                badgeBgColor = const Color(0xFFFEE2E2);
                                badgeTextColor = const Color(0xFF991B1B);
                              } else if (status == 'Izin' ||
                                  status == 'Libur') {
                                badgeBgColor = const Color(0xFFF3F4F6);
                                badgeTextColor = const Color(0xFF4B5563);
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: colorSurfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(68, 42, 34, 0.06),
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Staff Avatar
                                    _buildStaffAvatarBadge(staff, size: 44),
                                    const SizedBox(width: 10),

                                    // Staff Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff['name'] as String? ?? 'Staf',
                                            style: GoogleFonts.workSans(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 3,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                staff['role'] as String? ??
                                                    'Barista',
                                                style: GoogleFonts.workSans(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: colorOnSurfaceVariant,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1.5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _selectedShiftTab == 0
                                                      ? const Color(0xFFDCFCE7)
                                                      : const Color(0xFFE0F2FE),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _selectedShiftTab == 0
                                                      ? 'Shift Pagi'
                                                      : 'Shift Sore',
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        _selectedShiftTab == 0
                                                        ? const Color(
                                                            0xFF166534,
                                                          )
                                                        : const Color(
                                                            0xFF0369A1,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

                                          // Store Name & Shift Time Badge Row
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: [
                                              // Badge Store Name
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorPrimary
                                                      .withValues(alpha: 0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: colorPrimary
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.storefront_rounded,
                                                      size: 11,
                                                      color: colorPrimary,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      staff['storeName'] ??
                                                          (UserDataStore
                                                                  .instance
                                                                  .userDataNotifier
                                                                  .value['storeName'] ??
                                                              'Bella Cafe'),
                                                      style:
                                                          GoogleFonts.workSans(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: colorPrimary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Badge Shift Time
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorSecondaryContainer
                                                      .withValues(alpha: 0.45),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_rounded,
                                                      size: 11,
                                                      color: colorSecondary,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      _formatStaffShiftTime(
                                                        staff['shiftTime'],
                                                        _selectedShiftTab,
                                                      ),
                                                      style:
                                                          GoogleFonts.workSans(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                colorSecondary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // Status Badge, In-Time & Edit/Delete Action Buttons
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeBgColor,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            (staff['status'] as String? ??
                                                    'HADIR')
                                                .toUpperCase(),
                                            style: GoogleFonts.workSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              color: badgeTextColor,
                                            ),
                                          ),
                                        ),
                                        if (staff['time'] != null &&
                                            staff['time'] != '-') ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            staff['time'] as String,
                                            style: GoogleFonts.workSans(
                                              fontSize: 10.5,
                                              color: colorOnSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 5),

                                        // Edit and Delete Buttons Row
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Edit Button
                                            InkWell(
                                              onTap: () => _showEditStaffDialog(
                                                staff,
                                                index,
                                                _selectedShiftTab,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorSecondaryContainer
                                                      .withValues(alpha: 0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: colorSecondary
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.edit_outlined,
                                                      size: 11,
                                                      color: colorSecondary,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'Edit',
                                                      style:
                                                          GoogleFonts.workSans(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                colorSecondary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),

                                            // Delete Button
                                            InkWell(
                                              onTap: () =>
                                                  _showDeleteStaffDialog(
                                                    staff,
                                                    index,
                                                    _selectedShiftTab,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFEE2E2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFEF4444,
                                                    ).withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      size: 11,
                                                      color: Color(0xFFDC2626),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'Hapus',
                                                      style:
                                                          GoogleFonts.workSans(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color(
                                                              0xFFDC2626,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ] else if (_selectedTabIndex == 2) ...[
                        // TAB 3: DAFTAR TOKO & CABANG VIEW
                        _buildStoresTabView(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== TAB 3: DAFTAR TOKO & CABANG VIEW ====================
  Widget _buildStoresTabView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Title, Description, and + TOKO Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Cabang & Toko',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola outlet toko dan pilih toko aktif untuk operasional kasir.',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () async {
                await _showAddStoreDialog();
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorSecondary,
                foregroundColor: Colors.white,
                elevation: 1.5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.add_business_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                '+ TOKO',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Toko Aktif Saat Ini Card
        ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: UserDataStore.instance.userDataNotifier,
          builder: (context, userData, _) {
            final activeStore = userData['storeName'] ?? 'Bella Cafe';
            final activeLocation = userData['location'] ?? 'Jakarta';

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorSecondary.withValues(alpha: 0.12),
                    colorPrimary.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorSecondary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorSecondary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorSecondary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorGreenBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'TOKO AKTIF SAAT INI',
                                style: GoogleFonts.workSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: colorGreenText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeStore,
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: colorOnSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              activeLocation,
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Section Title: Seluruh Toko Terdaftar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Seluruh Toko',
              style: GoogleFonts.sourceSerif4(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            ValueListenableBuilder<List<String>>(
              valueListenable: UserDataStore.instance.storeListNotifier,
              builder: (context, storeNames, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorOutlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${storeNames.length} Toko Tersedia',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stream / Future Builder dari Database + UserDataStore
        ValueListenableBuilder<List<String>>(
          valueListenable: UserDataStore.instance.storeListNotifier,
          builder: (context, registeredStoreNames, _) {
            return ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: UserDataStore.instance.userDataNotifier,
              builder: (context, userData, _) {
                final currentActiveStoreName =
                    userData['storeName']?.toString().trim() ?? 'Bella Cafe';
                final currentActiveLocation =
                    userData['location']?.toString().trim() ?? 'Jakarta';

                return FutureBuilder<List<StoreModel>>(
                  future: DataBaseHelper().getAllStores(),
                  builder: (context, snapshot) {
                    final dbStores = snapshot.data ?? [];

                    // Map of all stores merged by store name (lowercase)
                    final Map<String, StoreModel> mergedStoresMap = {};

                    // 1. Fallback presets only if not explicitly deleted
                    final defaultPresets = [
                      StoreModel(
                        id: 1,
                        name: 'Bella Cafe',
                        location: 'Jakarta Selatan',
                        defaultShift: 'Pagi',
                      ),
                      StoreModel(
                        id: 2,
                        name: 'BGA Co. - Central Perk',
                        location: 'Jakarta Pusat',
                        defaultShift: 'Pagi',
                      ),
                      StoreModel(
                        id: 3,
                        name: 'BGA Co. - Downtown Latte',
                        location: 'Jakarta Selatan',
                        defaultShift: 'Sore',
                      ),
                      StoreModel(
                        id: 4,
                        name: 'BGA Co. - Westside Brew',
                        location: 'Jakarta Barat',
                        defaultShift: 'Pagi',
                      ),
                    ];
                    for (final s in defaultPresets) {
                      final trimmed = s.name.trim();
                      if (trimmed.isNotEmpty &&
                          !UserDataStore.instance.isStoreDeleted(trimmed)) {
                        mergedStoresMap[trimmed.toLowerCase()] = s;
                      }
                    }

                    // 2. Add stores from SQLite/Firestore database
                    for (final s in dbStores) {
                      final trimmed = s.name.trim();
                      if (trimmed.isNotEmpty &&
                          !UserDataStore.instance.isStoreDeleted(trimmed)) {
                        mergedStoresMap[trimmed.toLowerCase()] = s;
                      }
                    }

                    // 3. Add stores from UserDataStore storeListNotifier
                    for (final name in registeredStoreNames) {
                      final trimmed = name.trim();
                      if (trimmed.isEmpty) continue;
                      final key = trimmed.toLowerCase();
                      if (!UserDataStore.instance.isStoreDeleted(trimmed) &&
                          !mergedStoresMap.containsKey(key)) {
                        mergedStoresMap[key] = StoreModel(
                          name: trimmed,
                          location:
                              trimmed.toLowerCase() ==
                                  currentActiveStoreName.toLowerCase()
                              ? currentActiveLocation
                              : 'Indonesia',
                          defaultShift: 'Pagi',
                        );
                      }
                    }

                    // 4. Ensure current active store is in list if not deleted
                    final trimmedActive = currentActiveStoreName.trim();
                    if (trimmedActive.isNotEmpty &&
                        !UserDataStore.instance.isStoreDeleted(trimmedActive)) {
                      final key = trimmedActive.toLowerCase();
                      if (!mergedStoresMap.containsKey(key)) {
                        mergedStoresMap[key] = StoreModel(
                          name: trimmedActive,
                          location: currentActiveLocation.isNotEmpty
                              ? currentActiveLocation
                              : 'Indonesia',
                          defaultShift: 'Pagi',
                        );
                      }
                    }

                    final stores = mergedStoresMap.values.toList();

                    if (stores.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: colorSurfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorOutlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.store_mall_directory_outlined,
                              size: 48,
                              color: colorOnSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada toko yang terdaftar',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Klik tombol "+ TOKO" di atas untuk menambahkan toko baru.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: stores.map((store) {
                        final isActive =
                            store.name.trim().toLowerCase() ==
                            currentActiveStoreName.toLowerCase();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? colorSecondary
                                  : colorOutlineVariant.withValues(alpha: 0.4),
                              width: isActive ? 1.5 : 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(68, 42, 34, 0.06),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Store Icon Container
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? colorSecondary.withValues(alpha: 0.15)
                                      : colorSurfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    color: isActive
                                        ? colorSecondary
                                        : colorOnSurfaceVariant,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Store Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            store.name,
                                            style: GoogleFonts.workSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorGreenBg,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'AKTIF',
                                              style: GoogleFonts.workSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: colorGreenText,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 13,
                                          color: colorOnSurfaceVariant,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            store.location.isNotEmpty
                                                ? store.location
                                                : 'Indonesia',
                                            style: GoogleFonts.workSans(
                                              fontSize: 12,
                                              color: colorOnSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Actions: Pilih & Hapus Toko
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isActive)
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final currentUser = _auth.currentUser;
                                          if (currentUser != null) {
                                            await _firestore
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .set({
                                                  'storeName': store.name,
                                                  'location': store.location,
                                                  'lastActive':
                                                      FieldValue.serverTimestamp(),
                                                }, SetOptions(merge: true));
                                          }
                                          await _firestore
                                              .collection('active_session')
                                              .doc('current')
                                              .set({
                                                'storeName': store.name,
                                                'location': store.location,
                                                'timestamp':
                                                    FieldValue.serverTimestamp(),
                                              }, SetOptions(merge: true));
                                        } catch (e) {
                                          debugPrint(
                                            'Error syncing active store to Firestore: $e',
                                          );
                                        }

                                        await UserDataStore.instance
                                            .updateUserData({
                                              'storeName': store.name,
                                              'location': store.location,
                                            });
                                        if (mounted) {
                                          setState(() {});
                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Toko "${store.name}" berhasil diaktifkan! 🏪',
                                                style: GoogleFonts.workSans(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor: colorSecondary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            colorSecondaryContainer,
                                        foregroundColor: colorSecondary,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Pilih',
                                        style: GoogleFonts.workSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _showDeleteStoreDialog(store),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 14,
                                            color: Color(0xFFDC2626),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Hapus',
                                            style: GoogleFonts.workSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
