import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _namaC = TextEditingController();
  final TextEditingController _jamC = TextEditingController();

  String? _selectedPosisi;
  String? _selectedShift;

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
    _jamC.dispose();
    super.dispose();
  }

  void _handleSave() {
    final nama = _namaC.text.trim();
    final jam = _jamC.text.trim();

    if (nama.isEmpty || _selectedPosisi == null || _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap lengkapi semua informasi staf!',
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newStaff = {
      'name': nama,
      'role': _getRoleDisplayName(_selectedPosisi!),
      'status': 'Belum Hadir',
      'time': '-',
      'shiftTime': _selectedShift,
      'hours': jam.isNotEmpty ? jam : '40',
      'imageUrl': null,
      'initials': nama.length >= 2
          ? nama.substring(0, 2).toUpperCase()
          : nama.toUpperCase(),
    };

    Navigator.pop(context, newStaff);
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
              'Tambah Staf',
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
                        'Tambahkan anggota tim baru ke dalam jadwal operasional kafe.',
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
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Pilih foto profil dari galeri',
                                            style: GoogleFonts.workSans(),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorSurfaceContainerLow,
                                        border: Border.all(
                                          color: colorOutlineVariant,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 32,
                                        color: colorOutline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'UNGGAH FOTO PROFIL',
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: colorOnSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Format JPG atau PNG, maks. 2MB',
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
                            const SizedBox(height: 12),

                            Text(
                              'NAMA LENGKAP',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: colorOnSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: colorSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorOutlineVariant),
                              ),
                              child: TextField(
                                controller: _namaC,
                                style: GoogleFonts.workSans(
                                  color: colorOnSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama staf',
                                  hintStyle: GoogleFonts.workSans(
                                    color: colorOutlineVariant,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: colorOutline,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section 2: Peran & Jadwal
                            Text(
                              'Peran & Jadwal',
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
                            Container(
                              decoration: BoxDecoration(
                                color: colorSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorOutlineVariant),
                              ),
                              child: TextField(
                                controller: _jamC,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.workSans(
                                  color: colorOnSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Contoh: 40',
                                  hintStyle: GoogleFonts.workSans(
                                    color: colorOutlineVariant,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.timer_outlined,
                                    color: colorOutline,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: colorPrimary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
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
                                      letterSpacing: 1.0,
                                      color: colorPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                ElevatedButton.icon(
                                  onPressed: _handleSave,
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'SIMPAN STAF',
                                    style: GoogleFonts.workSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildPosisiDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POSISI',
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
          'WAKTU SHIFT',
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
}
