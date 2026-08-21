import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/add_staff_screen.dart';
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
    _selectedDate = DateTime(2026, 8, 14);
    _focusedMonth = DateTime(2026, 8, 1);
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

  // Data for Calendar View
  List<Map<String, dynamic>> get _staffCalendarList => [
    {
      'name': 'Siti Aminah',
      'initials': 'SA',
      'role': 'Head Barista',
      'bgColor': colorSecondaryContainer,
      'textColor': colorOnSecondaryContainer,
      'status': 'ON DUTY',
      'statusColor': colorGreenText,
    },
    {
      'name': 'Budi Santoso',
      'initials': 'BS',
      'role': 'Pâtissier',
      'bgColor': colorPrimaryContainer,
      'textColor': colorOnPrimaryContainer,
      'status': 'ON DUTY',
      'statusColor': colorGreenText,
    },
    {
      'name': 'Rizky Pratama',
      'initials': 'RP',
      'role': 'Kasir',
      'bgColor': colorSecondaryContainer,
      'textColor': colorOnSecondaryContainer,
      'status': 'Istirahat',
      'statusColor': colorSecondary,
    },
    {
      'name': 'Dewi Lestari',
      'initials': 'DW',
      'role': 'Pelayan',
      'bgColor': colorPrimaryContainer,
      'textColor': colorOnPrimaryContainer,
      'status': 'ON DUTY',
      'statusColor': colorGreenText,
    },
  ];

  // Data for Shift Management View
  final List<Map<String, dynamic>> _shiftRosterPagi = [
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
  ];

  final List<Map<String, dynamic>> _shiftRosterSore = [
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
  ];

  String _formatStaffShiftTime(dynamic shiftVal, int tabIndex) {
    if (shiftVal == null || shiftVal.toString().isEmpty) {
      return tabIndex == 0 ? '07:00 - 15:00 WIB' : '15:00 - 23:00 WIB';
    }
    final s = shiftVal.toString().toLowerCase();
    if (s == 'pagi') return '07:00 - 15:00 WIB';
    if (s == 'sore') return '14:30 - 22:30 WIB';
    if (s == 'middle') return '11:00 - 19:00 WIB';
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
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final storeName = nameC.text.trim();
                                  final location = locationC.text.trim();

                                  UserDataStore.instance.updateUserData({
                                    'storeName': storeName,
                                    'location': location,
                                  });

                                  Navigator.pop(context);

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

  Future<void> _showAddStaffDialog() async {
    final newStaff =
        await context.push(const AddStaffScreen()) as Map<String, dynamic>?;
    if (newStaff != null) {
      setState(() {
        if (_selectedShiftTab == 0) {
          _shiftRosterPagi.add(newStaff);
        } else {
          _shiftRosterSore.add(newStaff);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Staf ${newStaff['name']} berhasil ditambahkan!'),
            backgroundColor: colorSecondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                      // Main Top Tabs Navigation (CALENDAR vs MANAJEMEN SHIFT)
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
                                              width: 2,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'CALENDAR',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.workSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
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
                                              width: 2,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'MANAJEMEN SHIFT',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.workSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: _selectedTabIndex == 1
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
                                children: [
                                  GestureDetector(
                                    onTap: _selectDateViaPicker,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              monthFormat
                                                  .format(_focusedMonth)
                                                  .toUpperCase(),
                                              style: GoogleFonts.workSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                                color: colorSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              size: 20,
                                              color: colorSecondary,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateFormatFull.format(_selectedDate),
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: colorPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: _previousMonth,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colorOutlineVariant,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.chevron_left,
                                            size: 20,
                                            color: colorPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _nextMonth,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colorOutlineVariant,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.chevron_right,
                                            size: 20,
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
                                          (day) => SizedBox(
                                            width: 38,
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
                                      child: Center(
                                        child: Text(
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
                                      Icons.schedule,
                                      size: 18,
                                      color: colorSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${widget.activeShift} (Terpilih: ${DateFormat('d MMM yyyy', 'id_ID').format(_selectedDate)})',
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Who is on Shift',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            Text(
                              '${_staffCalendarList.length} Members',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Column(
                          children: _staffCalendarList.map((staff) {
                            final isRest = staff['status'] == 'Istirahat';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRest
                                      ? colorOutlineVariant.withValues(
                                          alpha: 0.3,
                                        )
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: staff['bgColor'] as Color,
                                        ),
                                        child: Center(
                                          child: Text(
                                            staff['initials'] as String,
                                            style: GoogleFonts.sourceSerif4(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  staff['textColor'] as Color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff['name'] as String,
                                            style: GoogleFonts.workSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: colorPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (staff['role'] as String)
                                                .toUpperCase(),
                                            style: GoogleFonts.workSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.8,
                                              color: colorOnSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: staff['statusColor'] as Color,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (staff['status'] as String)
                                            .toUpperCase(),
                                        style: GoogleFonts.workSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: staff['statusColor'] as Color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        // TAB 2: MANAJEMEN SHIFT VIEW
                        // Header Title & Description
                        Text(
                          'Manajemen Shift',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jadwal tugas harian dan status kehadiran staf toko.',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sub-Tabs (Shift Pagi vs Shift Sore)
                        Container(
                          decoration: BoxDecoration(
                            border: const Border(bottom: BorderSide(width: 1)),
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
                                                width: 2,
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
                                        letterSpacing: 1.0,
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
                                                width: 2,
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
                                        letterSpacing: 1.0,
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

                        // Shift Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
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
                                        Icons.schedule,
                                        size: 18,
                                        color: colorOnSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedShiftTab == 0
                                            ? '07:00 - 15:00 WIB'
                                            : '15:00 - 23:00 WIB',
                                        style: GoogleFonts.workSans(
                                          fontSize: 14,
                                          color: colorOnSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorPrimaryContainer.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colorPrimaryContainer.withValues(
                                      alpha: 0.3,
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
                                        letterSpacing: 0.8,
                                        color: colorOnSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedShiftTab == 0 ? '4/5' : '2/3',
                                      style: GoogleFonts.sourceSerif4(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Staff Roster Header & Action Buttons (+ Toko & + Staff)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Daftar Staf Bertugas',
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Button Toko
                                TextButton.icon(
                                  onPressed: _showAddStoreDialog,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    foregroundColor: colorSecondary,
                                  ),
                                  icon: Icon(
                                    Icons.add_business_rounded,
                                    size: 16,
                                    color: colorSecondary,
                                  ),
                                  label: Text(
                                    'TOKO',
                                    style: GoogleFonts.workSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                      color: colorSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Button Staf
                                TextButton.icon(
                                  onPressed: _showAddStaffDialog,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    foregroundColor: colorSecondary,
                                  ),
                                  icon: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: colorSecondary,
                                  ),
                                  label: Text(
                                    'STAF',
                                    style: GoogleFonts.workSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                      color: colorSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Staff Member Cards
                        ...(_selectedShiftTab == 0
                                ? _shiftRosterPagi
                                : _shiftRosterSore)
                            .map((staff) {
                              final isRest = staff['status'] == 'Istirahat';
                              final isAbsent = staff['status'] == 'Belum Hadir';

                              Color badgeBgColor = colorGreenBg;
                              Color badgeTextColor = colorGreenText;

                              if (isRest) {
                                badgeBgColor = colorSecondaryContainer
                                    .withValues(alpha: 0.5);
                                badgeTextColor = colorSecondary;
                              } else if (isAbsent) {
                                badgeBgColor = colorErrorContainer;
                                badgeTextColor = colorOnErrorContainer;
                              }

                              return Opacity(
                                opacity: isAbsent ? 0.75 : 1.0,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorSurfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorPrimary.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          // Staff Avatar Image / Fallback Initials
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: colorOutlineVariant
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: staff['imageUrl'] != null
                                                  ? Image.network(
                                                      staff['imageUrl']
                                                          as String,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => _buildInitialsAvatar(
                                                            staff['initials']
                                                                as String,
                                                          ),
                                                    )
                                                  : _buildInitialsAvatar(
                                                      staff['initials']
                                                          as String,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Staff Name, Role & Jam Shift
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff['name'] as String,
                                                style: GoogleFonts.workSans(
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: isAbsent
                                                      ? colorOnSurfaceVariant
                                                      : colorPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                staff['role'] as String,
                                                style: GoogleFonts.workSans(
                                                  fontSize: 12.5,
                                                  color: colorOnSurfaceVariant,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2.5,
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
                                                      size: 12,
                                                      color: colorSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatStaffShiftTime(
                                                        staff['shiftTime'],
                                                        _selectedShiftTab,
                                                      ),
                                                      style:
                                                          GoogleFonts.workSans(
                                                            fontSize: 11,
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

                                      // Status Badge & In Time
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: badgeBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              (staff['status'] as String)
                                                  .toUpperCase(),
                                              style: GoogleFonts.workSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.6,
                                                color: badgeTextColor,
                                              ),
                                            ),
                                          ),
                                          if (staff['time'] != '-') ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              staff['time'] as String,
                                              style: GoogleFonts.workSans(
                                                fontSize: 12,
                                                color: colorOnSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
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

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: colorSurfaceContainerHigh,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.sourceSerif4(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorPrimary,
          ),
        ),
      ),
    );
  }
}
