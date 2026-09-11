import 'dart:typed_data';
import 'package:cashier/halaman1/database/database_helper.dart';
import 'package:cashier/halaman1/models/staff_model.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _namaC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _jamC = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedPosisi;
  String? _selectedShift;
  String? _selectedStore;
  Uint8List? _avatarBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UserDataStore.instance.initFromFirebase();
    _selectedStore = UserDataStore.instance.userDataNotifier.value['storeName'] as String? ?? 'Bella Cafe';
  }

  final ImagePicker _picker = ImagePicker();

  // Dynamic Color Tokens linked to AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurface => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorOnSurface => AppTheme.instance.onSurfaceColor;

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _jamC.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Sumber Foto',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: colorPrimary),
                  title: Text(
                    'Ambil Foto dari Kamera',
                    style: GoogleFonts.workSans(color: colorOnSurface),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colorPrimary,
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: GoogleFonts.workSans(color: colorOnSurface),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_avatarBytes != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFBA1A1A),
                    ),
                    title: Text(
                      'Hapus Foto',
                      style: GoogleFonts.workSans(
                        color: const Color(0xFFBA1A1A),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _avatarBytes = null;
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

  Future<void> _handleSave() async {
    final nama = _namaC.text.trim();
    final email = _emailC.text.trim();
    final phone = _phoneC.text.trim();
    final jam = _jamC.text.trim();

    if (nama.isEmpty || _selectedPosisi == null || _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap lengkapi nama staf, posisi, dan shift!',
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final roleName = _getRoleDisplayName(_selectedPosisi!);
    final initials = nama.length >= 2
        ? nama.substring(0, 2).toUpperCase()
        : nama.toUpperCase();

    final selectedStoreName = _selectedStore ??
        (UserDataStore.instance.userDataNotifier.value['storeName'] as String? ?? 'Bella Cafe');

    // 1. Create Staff Model for Firestore
    final staffModel = StaffModel(
      name: nama,
      role: roleName,
      phone: phone.isNotEmpty ? phone : null,
      email: email.isNotEmpty ? email : null,
      status: 'Hadir',
      initials: initials,
      avatarBytes: _avatarBytes,
    );

    int newStaffId = DateTime.now().millisecondsSinceEpoch;
    try {
      newStaffId = await DataBaseHelper().insertStaff(staffModel);

      // Simpan langsung ke koleksi 'staff' di Cloud Firestore
      final staffDocId = 'staff_$newStaffId';
      await _firestore.collection('staff').doc(staffDocId).set({
        'id': newStaffId,
        'name': nama,
        'role': roleName,
        'phone': phone.isNotEmpty ? phone : null,
        'email': email.isNotEmpty ? email : null,
        'status': 'Hadir',
        'storeName': selectedStoreName,
        'initials': initials,
        'hours': jam.isNotEmpty ? jam : '40',
        'shift': _selectedShift,
        'avatar_bytes': _avatarBytes != null ? _avatarBytes!.toList() : null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Simpan jadwal shift ke koleksi 'shifts' di Cloud Firestore
      final now = DateTime.now();
      final dateKey = UserDataStore.instance.formatDateKey(now);
      await _firestore
          .collection('shifts')
          .doc('${dateKey}_$newStaffId')
          .set({
        'date': dateKey,
        'staff_id': newStaffId,
        'staff_name': nama,
        'role': roleName,
        'shift_type': _selectedShift,
        'store_name': selectedStoreName,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore insertStaff error: $e');
    }

    final newStaff = {
      'id': newStaffId,
      'name': nama,
      'role': roleName,
      'status': 'Hadir',
      'storeName': selectedStoreName,
      'time': _selectedShift == 'pagi' ? 'In: 07:00' : 'In: 15:00',
      'shiftTime': _selectedShift,
      'hours': jam.isNotEmpty ? jam : '40',
      'phone': phone,
      'email': email,
      'imageUrl': null,
      'avatarBytes': _avatarBytes,
      'initials': initials,
    };

    try {
      await UserDataStore.instance.addCafeStaff(newStaff);
      await UserDataStore.instance.addStaffToRoster(
        _selectedShift == 'pagi' ? 0 : 1,
        newStaff,
        activeDate: DateTime.now(),
      );
      await UserDataStore.instance.reloadStaffList();
      await UserDataStore.instance.reloadShiftsForDate(DateTime.now());
    } catch (e) {
      debugPrint('UserDataStore update error: $e');
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context, newStaff);
    }
  }

  String _getRoleDisplayName(String value) {
    switch (value) {
      case 'barista':
        return 'Head Barista';
      case 'kasir':
        return 'Kasir';
      case 'runner':
        return 'Runner';
      case 'kitchen':
        return 'Kitchen Staff';
      default:
        return 'Staf';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: colorBackground,

          // Top App Bar
          appBar: AppBar(
            backgroundColor: colorSurface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Tambah Staf Firebase',
              style: GoogleFonts.sourceSerif4(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            centerTitle: false,
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle Header
                      Text(
                        'Tambahkan anggota tim baru ke dalam database Cloud Firestore kafe.',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bento-style Form Container Card
                      Container(
                        decoration: BoxDecoration(
                          color: colorSurfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(68, 42, 34, 0.05),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section: Upload Photo
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _showImagePickerModal,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 104,
                                          height: 104,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorSurfaceContainerLow,
                                            border: Border.all(
                                              color: colorPrimary.withValues(
                                                alpha: 0.5,
                                              ),
                                              width: 2.5,
                                            ),
                                            image: _avatarBytes != null
                                                ? DecorationImage(
                                                    image: MemoryImage(
                                                      _avatarBytes!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: _avatarBytes == null
                                              ? Icon(
                                                  Icons.add_a_photo_outlined,
                                                  size: 34,
                                                  color: colorPrimary,
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: colorPrimary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'FOTO PROFIL KARYAWAN',
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: colorOnSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tersimpan otomatis di Firestore',
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      color: colorOnSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Divider(color: colorOutlineVariant, height: 1),
                            const SizedBox(height: 24),

                            // Section 1: Informasi Dasar
                            Text(
                              'Informasi Dasar',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field: Nama Lengkap
                            Text(
                              'NAMA LENGKAP *',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: colorOnSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInputField(
                              controller: _namaC,
                              hint: 'Masukkan nama staf',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),

                            // Field: Email
                            Text(
                              'EMAIL STAF (OPSIONAL)',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: colorOnSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInputField(
                              controller: _emailC,
                              hint: 'staf@bgaco.com',
                              icon: Icons.email_outlined,
                              inputType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Field: Nomor HP
                            Text(
                              'NOMOR TELEPON / WHATSAPP',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: colorOnSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInputField(
                              controller: _phoneC,
                              hint: '08123456789',
                              icon: Icons.phone_outlined,
                              inputType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),

                            // Section 2: Peran & Jadwal
                            Text(
                              'Peran & Jadwal Shift',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 480;
                                return isWide
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildPosisiDropdown(),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildShiftDropdown(),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _buildPosisiDropdown(),
                                          const SizedBox(height: 16),
                                          _buildShiftDropdown(),
                                        ],
                                      );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Pilihan Toko / Outlet Bertugas
                            _buildStoreDropdown(),
                            const SizedBox(height: 16),

                            // Input: Total Jam per Minggu
                            Text(
                              'TOTAL JAM PER MINGGU (ESTIMASI)',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: colorOnSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInputField(
                              controller: _jamC,
                              hint: 'Contoh: 40',
                              icon: Icons.timer_outlined,
                              inputType: TextInputType.number,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Standar full-time adalah 40 jam.',
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Action Buttons (Batal & Simpan Staf)
                            Divider(color: colorOutlineVariant, height: 1),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: colorPrimary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'BATAL',
                                      style: GoogleFonts.workSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                        color: colorPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _handleSave,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                    label: Text(
                                      _isLoading
                                          ? 'MENYIMPAN...'
                                          : 'SIMPAN STAF',
                                      style: GoogleFonts.workSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorOutlineVariant),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: GoogleFonts.workSans(color: colorOnSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.workSans(color: colorOutlineVariant),
          prefixIcon: Icon(icon, color: colorOutline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPosisiDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POSISI *',
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colorOnSurface,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorOutlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPosisi,
              hint: Row(
                children: [
                  Icon(Icons.badge_outlined, color: colorOutline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pilih posisi...',
                    style: GoogleFonts.workSans(color: colorOutlineVariant),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: colorOutline),
              items: const [
                DropdownMenuItem(value: 'barista', child: Text('Barista')),
                DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                DropdownMenuItem(value: 'runner', child: Text('Runner')),
                DropdownMenuItem(
                  value: 'kitchen',
                  child: Text('Kitchen Staff'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedPosisi = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WAKTU SHIFT *',
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colorOnSurface,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorOutlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedShift,
              hint: Row(
                children: [
                  Icon(Icons.schedule, color: colorOutline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pilih shift...',
                    style: GoogleFonts.workSans(color: colorOutlineVariant),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: colorOutline),
              items: const [
                DropdownMenuItem(
                  value: 'pagi',
                  child: Text('Pagi (07:00 - 15:00)'),
                ),
                DropdownMenuItem(
                  value: 'middle',
                  child: Text('Middle (11:00 - 19:00)'),
                ),
                DropdownMenuItem(
                  value: 'sore',
                  child: Text('Sore (14:30 - 22:30)'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedShift = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOKO / OUTLET BERTUGAS *',
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colorOnSurface,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<List<String>>(
          valueListenable: UserDataStore.instance.storeListNotifier,
          builder: (context, stores, _) {
            final storeOptions = List<String>.from(stores);
            if (_selectedStore != null &&
                _selectedStore!.isNotEmpty &&
                !storeOptions.contains(_selectedStore!)) {
              storeOptions.insert(0, _selectedStore!);
            }
            if (storeOptions.isEmpty) {
              storeOptions.add('Bella Cafe');
            }
            final currentVal = storeOptions.contains(_selectedStore)
                ? _selectedStore
                : storeOptions.first;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorOutlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentVal,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: colorOutline),
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
                                color: colorOnSurface,
                                fontWeight: FontWeight.w500,
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
                      setState(() => _selectedStore = val);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
