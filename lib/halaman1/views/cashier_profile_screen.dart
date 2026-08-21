import 'dart:typed_data';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/staff_shift_screen.dart';
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

class _CashierProfileScreenState extends State<CashierProfileScreen> {
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

  // State for interactive avatar editing
  Uint8List? _imageBytes;
  String? _customAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  // Data Daftar Karyawan Cafe (Kerja, Shift Sore, & Libur)
  final List<Map<String, dynamic>> _cafeStaffList = [
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
  ];

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

          // AppBar with Back Button to return to Home/Dashboard
          appBar: AppBar(
            backgroundColor: colorBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile Kasir',
              style: GoogleFonts.sourceSerif4(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: colorPrimary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
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
                        widget.name,
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
                        widget.role,
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
                            '${widget.storeName} - ${widget.storeLocation}',
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              color: colorOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorSecondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Shift: ${widget.shift}',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorOnSecondaryContainer,
                          ),
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
            ),
          ),
        );
      },
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
                    vertical: 4,
                  ),
                  child: Row(
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
                        size: 12,
                        color: colorSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Daftar seluruh karyawan Bella Cafe:',
            style: GoogleFonts.workSans(
              fontSize: 13,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // List Staff Cards
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
                                    staff['initials'],
                                    style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.bold,
                                      color: colorOnSecondaryContainer,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  staff['initials'],
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
                            staff['name'],
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            staff['role'],
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
            },
          ),
        ],
      ),
    );
  }
}
