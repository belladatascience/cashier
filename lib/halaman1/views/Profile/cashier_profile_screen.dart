import 'dart:typed_data';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/Shift/staff_shift_screen.dart';
import 'package:cashier/halaman1/views/setting/edit_personal_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CashierProfileScreen extends StatefulWidget {
  final String storeName;
  final String storeLocation;
  final String shift;
  final String name;
  final String role;
  final String shiftDuration;
  final String totalTransactions;
  final String totalSales;
  final String avatarUrl;

  const CashierProfileScreen({
    super.key,
    this.storeName = 'Bella Cafe',
    this.storeLocation = 'Jakarta',
    this.shift = 'Pagi',
    this.name = 'Alex Johnson',
    this.role = 'Senior Cashier',
    this.shiftDuration = '6h 45m',
    this.totalTransactions = '142',
    this.totalSales = 'Rp 4.250.000',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
  });

  @override
  State<CashierProfileScreen> createState() => _CashierProfileScreenState();
}

class _CashierProfileScreenState extends State<CashierProfileScreen>
    with SingleTickerProviderStateMixin {
  // Dynamic Color Tokens linked to AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorTertiaryFixed => AppTheme.instance.isDarkMode
      ? const Color(0xFF32302D)
      : const Color(0xFFE2E6BF);
  Color get colorOnTertiaryFixed => AppTheme.instance.isDarkMode
      ? const Color(0xFFF0BD8B)
      : const Color(0xFF1A1D06);
  Color get colorSecondaryContainer => AppTheme.instance.secondaryContainer;
  Color get colorOnSecondaryContainer => AppTheme.instance.onSecondaryContainer;
  Color get colorPrimaryFixedDim => AppTheme.instance.isDarkMode
      ? const Color(0xFF3B3835)
      : const Color(0xFFE7BDB1);

  // State for interactive profile editing
  late String _cashierName;
  late String _cashierRole;
  late String _storeName;
  late String _storeLocation;
  late String _shift;
  late DateTime _startDate;

  // Account Profile State
  late String _accountName;
  late String _email;
  late String _phone;
  late String _nik;
  late String _statusAkun;
  late String _lastLogin;
  late TabController _tabController;

  Uint8List? _imageBytes;
  String? _customAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFromUserDataStore();
    UserDataStore.instance.userDataNotifier.addListener(_loadFromUserDataStore);
  }

  void _loadFromUserDataStore() {
    final data = UserDataStore.instance.userDataNotifier.value;
    final fbUser = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _cashierName = data['cashierName'] ?? fbUser?.displayName ?? data['name'] ?? widget.name;
        _cashierRole = data['cashierRole'] ?? data['role'] ?? widget.role;
        _storeName = data['storeName'] ?? widget.storeName;
        _storeLocation = data['location'] ?? widget.storeLocation;
        _shift = data['shift'] ?? widget.shift;
        _startDate = data['startDate'] ?? DateTime(2024, 1, 15);
        _accountName = data['accountName'] ?? fbUser?.displayName ?? 'Bella Gita Asmara';
        _email = data['email'] ?? fbUser?.email ?? 'bella.gita@bgaco.com';
        _phone = data['phone'] ?? fbUser?.phoneNumber ?? '087888848000';
        _nik = data['cashierId'] ?? (fbUser != null ? 'BG' : 'BG188889');
        _statusAkun = fbUser != null
            ? (fbUser.emailVerified ? 'Aktif (Firebase Verified)' : 'Aktif (Firebase)')
            : 'Aktif (Verified)';
        _lastLogin = 'Hari ini, : WIB';
        if (data['avatarBytes'] != null) {
          _imageBytes = data['avatarBytes'];
        }
      });
    }
  }

  Future<void> _openEditPersonalInfoScreen() async {
    final result = await context.push(const EditPersonalInfoScreen());
    if (result != null && result is Map<String, dynamic>) {
      _loadFromUserDataStore();
    }
  }

  @override
  void dispose() {
    UserDataStore.instance.userDataNotifier.removeListener(
      _loadFromUserDataStore,
    );
    _tabController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  // ignore: unused_element
  String get _formattedStartDate {
    return '${_startDate.day} ${_getMonthName(_startDate.month)} ${_startDate.year}';
  }

  // ignore: unused_element
  String get _tenureString {
    final now = DateTime.now();
    int years = now.year - _startDate.year;
    int months = now.month - _startDate.month;
    if (now.day < _startDate.day) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0 && months > 0) {
      return '$years Tahun $months Bulan';
    } else if (years > 0) {
      return '$years Tahun';
    } else if (months > 0) {
      return '$months Bulan';
    }
    return 'Kurang dari 1 Bulan';
  }

  String get _shiftHours {
    final s = _shift.toLowerCase();
    if (s.contains('siang') || s.contains('sore')) {
      return '15:00 - 23:00 WIB';
    } else if (s.contains('malam')) {
      return '23:00 - 07:00 WIB';
    }
    return '07:00 - 15:00 WIB';
  }

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _cashierName);
    final roleController = TextEditingController(text: _cashierRole);
    final storeController = TextEditingController(text: _storeName);
    final locationController = TextEditingController(text: _storeLocation);
    String tempShift = _shift;
    DateTime tempStartDate = _startDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorOutlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Profil Kasir',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nama Kasir
                    Text(
                      'NAMA KASIR',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Jabatan / Role
                    Text(
                      'JABATAN / ROLE',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: roleController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Store Name & Location Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NAMA TOKO',
                                style: GoogleFonts.workSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: colorOnSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: storeController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.storefront),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LOKASI TOKO',
                                style: GoogleFonts.workSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: colorOnSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: locationController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Shift Kerja Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHIFT KERJA',
                          style: GoogleFonts.workSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: tempShift,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: ['Pagi', 'Sore', 'Malam']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => tempShift = val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _cashierName = nameController.text.trim();
                            _cashierRole = roleController.text.trim();
                            _storeName = storeController.text.trim();
                            _storeLocation = locationController.text.trim();
                            _shift = tempShift;
                            _startDate = tempStartDate;
                          });
                          UserDataStore.instance.updateUserData({
                            'cashierName': _cashierName,
                            'cashierRole': _cashierRole,
                            'storeName': _storeName,
                            'location': _storeLocation,
                            'shift': _shift,
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Profil kasir berhasil diperbarui!',
                              ),
                              backgroundColor: colorSecondary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'SIMPAN PERUBAHAN',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Persistent Data from UserDataStore singleton
  List<Map<String, dynamic>> get _cafeStaffList =>
      UserDataStore.instance.cafeStaffList;

  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Barista');
    String? errorMessage;

    final List<String> rolePresets = [
      'Head Barista',
      'Barista',
      'Barista Assistant',
      'Kasir',
      'PÃ¢tissier',
      'Pelayan',
      'Kitchen Crew',
      'Supervisor',
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
                      // Header Icon & Title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: colorPrimary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 30,
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tambah Staff Baru',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Masukkan informasi karyawan baru cafe.',
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

                      // Nama Lengkap Staff
                      Text(
                        'Nama Lengkap Staff',
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
                          hintText: 'Contoh: Bambang Saputra',
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

                      // Jabatan / Posisi
                      Text(
                        'Jabatan / Posisi',
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

                      // Preset Role Chips
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
                                    ? colorPrimary
                                    : colorSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? colorPrimary
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

                          if (name.isEmpty) {
                            setDialogState(() {
                              errorMessage = 'Nama Staff tidak boleh kosong!';
                            });
                            return;
                          }
                          if (role.isEmpty) {
                            setDialogState(() {
                              errorMessage = 'Jabatan tidak boleh kosong!';
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

                          final newStaffData = {
                            'name': name,
                            'role': role,
                            'avatarUrl': null,
                            'initials': inits,
                          };

                          setState(() {
                            UserDataStore.instance.addCafeStaff(newStaffData);
                          });

                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Staff $name ($role) berhasil ditambahkan! ðŸ‘¤',
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: colorPrimary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Simpan Staff'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: colorPrimary,
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

  void _showDeleteCafeStaffDialog(Map<String, dynamic> staff, int index) {
    final name = staff['name'] ?? 'Karyawan';
    final role = staff['role'] ?? 'Staff';

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
                  'Hapus Karyawan?',
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
            'Apakah Anda yakin ingin menghapus $name ($role) dari daftar karyawan?',
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
                        UserDataStore.instance.deleteCafeStaff(index);
                      });
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Karyawan $name berhasil dihapus! ðŸ—‘ï¸',
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _customAvatarUrl = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto profil berhasil diperbarui!'),
              backgroundColor: colorSecondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChangePhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorOutlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Ubah Foto Profil',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorSecondaryContainer,
                    child: Icon(
                      Icons.photo_library,
                      color: colorOnSecondaryContainer,
                    ),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorTertiaryFixed,
                    child: Icon(Icons.camera_alt, color: colorOnTertiaryFixed),
                  ),
                  title: Text(
                    'Ambil Foto Kamera',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorSurfaceContainerLow,
                    child: Icon(Icons.link, color: colorPrimary),
                  ),
                  title: Text(
                    'Input URL Gambar',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showUrlInputDialog();
                  },
                ),
                if (_imageBytes != null || _customAvatarUrl != null)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade700,
                      ),
                    ),
                    title: Text(
                      'Hapus / Reset Foto',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imageBytes = null;
                        _customAvatarUrl = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUrlInputDialog() {
    final controller = TextEditingController(text: _customAvatarUrl ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Input URL Foto Profil',
          style: GoogleFonts.sourceSerif4(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/avatar.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOnSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _customAvatarUrl = controller.text.trim();
                  _imageBytes = null;
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget() {
    Widget imageWidget;
    if (_imageBytes != null) {
      imageWidget = Image.memory(_imageBytes!, fit: BoxFit.cover);
    } else if (_customAvatarUrl != null) {
      imageWidget = Image.network(
        _customAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
      );
    } else {
      imageWidget = Image.network(
        widget.avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: _showChangePhotoOptions,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorSecondary.withValues(alpha: 0.3),
                width: 4,
              ),
              color: colorSurfaceContainerLow,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(child: imageWidget),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: InkWell(
            onTap: _showChangePhotoOptions,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: colorSecondaryContainer,
      child: Icon(Icons.person, size: 72, color: colorOnSecondaryContainer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: colorBackground,

          // AppBar with Back Button
          appBar: AppBar(
            backgroundColor: colorBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile',
              style: GoogleFonts.sourceSerif4(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.edit_note_outlined, color: colorPrimary),
                tooltip: 'Edit Profil',
                onPressed: _openEditPersonalInfoScreen,
              ),
              const SizedBox(width: 8),
            ],
          ),

          body: SafeArea(
            child: Column(
              children: [
                // Top Tab Bar Selection (Profile Kasir & Profile Akun)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: colorOnSurfaceVariant,
                    labelStyle: GoogleFonts.workSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: GoogleFonts.workSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.badge_outlined, size: 18),
                        text: 'Profile Kasir',
                      ),
                      Tab(
                        icon: Icon(Icons.manage_accounts_outlined, size: 18),
                        text: 'Profile Akun',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Tab Content View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCashierProfileTab(),
                      _buildAccountProfileTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== TAB 1: PROFILE KASIR ====================
  Widget _buildCashierProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Interactive Profile Header Avatar
              _buildAvatarWidget(),
              const SizedBox(height: 16),

              Text(
                _cashierName,
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSerif4(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _cashierRole,
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorOnSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_storeName - $_storeLocation',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Edit Profile Button
              OutlinedButton.icon(
                onPressed: _showEditProfileModal,
                icon: const Icon(Icons.edit_note, size: 18),
                label: Text(
                  'Edit Profil Kasir',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorPrimary,
                  side: BorderSide(color: colorPrimary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Work Start & Tenure Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorOutlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorSecondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.access_time_filled,
                        color: colorOnSecondaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Shift & Jam Kerja',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: colorOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Shift: $_shift',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jam: $_shiftHours',
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorTertiaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aktif',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorOnTertiaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Daftar Staff / Karyawan Bertugas
              _buildOnDutyStaffSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 2: PROFILE AKUN ====================
  Widget _buildAccountProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Account Header Banner Card
              _buildAccountHeaderCard(),
              const SizedBox(height: 20),

              // Account Details List Card
              _buildAccountDetailsCard(),
              const SizedBox(height: 20),

              // POS Authorizations Card
              _buildPosAuthorizationCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.manage_accounts, color: colorPrimary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _accountName,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Verified',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Kasir: $_nik',
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Login Terakhir: $_lastLogin',
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
    );
  }

  Widget _buildAccountDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Akun',
            style: GoogleFonts.sourceSerif4(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildAccountRow(
            icon: Icons.email_outlined,
            label: 'Email Terdaftar',
            value: _email,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _buildAccountRow(
            icon: Icons.phone_android_outlined,
            label: 'No. Telepon / WhatsApp',
            value: _phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _buildAccountRow(
            icon: Icons.badge_outlined,
            label: 'ID Anggota / NIK Karyawan',
            value: _nik,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _buildAccountRow(
            icon: Icons.verified_user_outlined,
            label: 'Status Otorisasi Akun',
            value: _statusAkun,
            valueColor: const Color(0xFF166534),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorPrimary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: colorOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? colorPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildAccountSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keamanan Akun',
            style: GoogleFonts.sourceSerif4(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorSecondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_reset_outlined,
                color: colorOnSecondaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              'Ubah Kata Sandi',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Diperbarui 30 hari yang lalu',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: colorOnSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _showChangePasswordModal,
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security_outlined,
                color: Color(0xFF166534),
                size: 20,
              ),
            ),
            title: Text(
              'Verifikasi 2-Langkah (2FA)',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Aktif via WhatsApp / SMS',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: const Color(0xFF166534),
              ),
            ),
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeThumbColor: colorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosAuthorizationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hak Akses POS Kasir',
            style: GoogleFonts.sourceSerif4(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildAuthItem('Akses Buka Laci Kasir (Cash Drawer)', true),
          _buildAuthItem(
            'Proses Void / Batal Transaksi',
            false,
            note: 'Butuh PIN Supervisor',
          ),
          _buildAuthItem('Pemberian Diskon Manual', true),
          _buildAuthItem('Cetak Laporan Penjualan Shift', true),
        ],
      ),
    );
  }

  Widget _buildAuthItem(String title, bool isAllowed, {String? note}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorPrimary,
                  ),
                ),
                if (note != null)
                  Text(
                    note,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      color: colorSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isAllowed ? Icons.check_circle : Icons.lock_outline,
            color: isAllowed ? const Color(0xFF166534) : Colors.orange.shade800,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showEditAccountModal() {
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    final nikController = TextEditingController(text: _nik);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorOutlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Informasi Akun',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                Text(
                  'EMAIL TERDAFTAR',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colorOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone
                Text(
                  'NO. TELEPON / WHATSAPP',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colorOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // NIK / ID Anggota
                Text(
                  'ID ANGGOTA / NIK KARYAWAN',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colorOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nikController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final newEmail = emailController.text.trim();
                      final newPhone = phoneController.text.trim();
                      final newNik = nikController.text.trim();

                      setState(() {
                        _email = newEmail;
                        _phone = newPhone;
                        _nik = newNik;
                      });

                      UserDataStore.instance.updateUserData({
                        'email': newEmail,
                        'phone': newPhone,
                        'cashierId': newNik,
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Informasi akun berhasil diperbarui!',
                          ),
                          backgroundColor: colorSecondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'SIMPAN PERUBAHAN AKUN',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordModal() {
    final oldPasswordC = TextEditingController();
    final newPasswordC = TextEditingController();
    final confirmPasswordC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ubah Kata Sandi',
          style: GoogleFonts.sourceSerif4(
            fontWeight: FontWeight.bold,
            color: colorPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Kata Sandi Baru',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOnSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Kata sandi berhasil diubah!'),
                  backgroundColor: colorSecondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorOnSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.workSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.sourceSerif4(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStatCardTransactions() {
    return _buildStatCard(
      title: 'Total Transaksi',
      value: widget.totalTransactions,
      icon: Icons.receipt_long_outlined,
      subtitle: 'Hari ini',
      iconColor: colorSecondary,
      iconBgColor: colorSecondaryContainer,
    );
  }

  // ignore: unused_element
  Widget _buildStatCardSales() {
    return _buildStatCard(
      title: 'Total Penjualan',
      value: widget.totalSales,
      icon: Icons.payments_outlined,
      subtitle: 'Shift ini',
      iconColor: colorPrimary,
      iconBgColor: colorPrimaryFixedDim,
    );
  }

  Widget _buildOnDutyStaffSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorSecondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.groups_outlined,
                      color: colorOnSecondaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Daftar Karyawan',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      context.push(
                        StaffShiftScreen(
                          activeShift: '${widget.shift} Shift: 07:00 - 15:00',
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kelola Shift',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: colorSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _showAddStaffDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+ Staff',
                            style: GoogleFonts.workSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
          const SizedBox(height: 6),
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: UserDataStore.instance.userDataNotifier,
            builder: (context, userData, _) {
              final store =
                  userData['storeName'] ??
                  (widget.storeName.isNotEmpty
                      ? widget.storeName
                      : 'Kingdom Cafe');
              return Text(
                'Daftar seluruh karyawan $store:',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: colorOnSurfaceVariant,
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // List Staff Cards
          if (_cafeStaffList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 36,
                    color: colorOnSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada karyawan terdaftar',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cafeStaffList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final staff = _cafeStaffList[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorOutlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar / Initials
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 44,
                          height: 44,
                          color: colorSecondaryContainer,
                          child: staff['avatarUrl'] != null
                              ? Image.network(
                                  staff['avatarUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      staff['initials'] ?? 'ST',
                                      style: GoogleFonts.workSans(
                                        fontWeight: FontWeight.bold,
                                        color: colorOnSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    staff['initials'] ?? 'ST',
                                    style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.bold,
                                      color: colorOnSecondaryContainer,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Staff Name & Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff['name'] ?? 'Karyawan',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              staff['role'] ?? 'Staff',
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tombol Hapus / Delete Karyawan
                      InkWell(
                        onTap: () => _showDeleteCafeStaffDialog(staff, index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                size: 15,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hapus',
                                style: GoogleFonts.workSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
