import 'dart:typed_data';
import 'package:cashier/CASHIER/database/database_helper.dart';
import 'package:cashier/CASHIER/models/user_login.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/utils/user_data_store.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class DataUserCashier extends StatefulWidget {
  const DataUserCashier({super.key});

  @override
  State<DataUserCashier> createState() => _DataUserCashierState();
}

class _DataUserCashierState extends State<DataUserCashier> {
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurface => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOnSurface => AppTheme.instance.onSurfaceColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorError => const Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kelola Data Pengguna',
          style: GoogleFonts.sourceSerif4(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah Pengguna Baru',
            icon: Icon(Icons.person_add_alt_1_rounded, color: colorSecondary),
            onPressed: () {
              _showBottomSheet(context, null);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah Pengguna',
          style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        onPressed: () {
          _showBottomSheet(context, null);
        },
      ),
      body: StreamBuilder<List<UserModelSQL>>(
        stream: DataBaseHelper().streamUsers(),
        builder: (context, snapshot) {
          // Status 1: Sedang memuat data dari Firestore
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
              ),
            );
          }

          // Status 2: Terjadi error saat membaca data
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 48, color: colorError),
                  const SizedBox(height: 12),
                  Text(
                    'Terjadi kesalahan memuat data Firestore:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      color: colorError,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final daftarPengguna = snapshot.data ?? [];

          // Status 3: Data kosong / belum ada pengguna di database
          if (daftarPengguna.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: colorOutlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada data pengguna di Firebase.',
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      color: colorOnSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk tombol Tambah untuk membuat akun kasir baru.',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOutlineVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Status 4: Data berhasil diambil dari Firestore
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: daftarPengguna.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = daftarPengguna[index];
              final displayName = (user.nama != null && user.nama!.isNotEmpty)
                  ? user.nama!
                  : user.email;
              final initials = displayName.isNotEmpty
                  ? displayName.trim().substring(0, 1).toUpperCase()
                  : 'U';

              return Container(
                decoration: BoxDecoration(
                  color: colorSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorOutlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: colorSecondary.withValues(alpha: 0.15),
                    backgroundImage: user.avatarBytes != null
                        ? MemoryImage(user.avatarBytes!)
                        : null,
                    child: user.avatarBytes == null
                        ? Text(
                            initials,
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorSecondary,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    displayName,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorOnSurface,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: colorOnSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.email,
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  color: colorOnSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: colorOnSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              user.nomor_hp?.isNotEmpty == true ? user.nomor_hp! : '-',
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_city_outlined, size: 14, color: colorOnSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              user.asalKota?.isNotEmpty == true ? user.asalKota! : 'Jakarta',
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        tooltip: 'Edit Data',
                        icon: Icon(Icons.edit_outlined, color: colorSecondary),
                        onPressed: () {
                          _showBottomSheet(context, user);
                        },
                      ),
                      // Tombol Hapus
                      IconButton(
                        tooltip: 'Hapus Akun',
                        icon: Icon(Icons.delete_outline_rounded, color: colorError),
                        onPressed: () {
                          _showDeleteConfirmation(context, user);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModelSQL user) {
    final accountTitle = (user.nama != null && user.nama!.isNotEmpty)
        ? user.nama!
        : user.email;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorError),
            const SizedBox(width: 8),
            Text(
              'Hapus Pengguna',
              style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold, color: colorPrimary),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun "$accountTitle" dari Firebase?',
          style: GoogleFonts.workSans(color: colorOnSurfaceVariant, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOnSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorError,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (user.id != null) {
                await DataBaseHelper().deleteUser(user.id!);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pengguna ${user.email} berhasil dihapus dari Firestore'),
                    backgroundColor: colorSecondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Modal Bottom Sheet untuk Tambah / Edit pengguna di Cloud Firestore
  void _showBottomSheet(BuildContext context, UserModelSQL? user) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.nama ?? "");
    final emailController = TextEditingController(text: user?.email ?? "");
    final passwordController = TextEditingController(text: user?.password ?? "");
    final noHpController = TextEditingController(text: user?.nomor_hp ?? "");
    final cityController = TextEditingController(text: user?.asalKota ?? "");
    Uint8List? selectedAvatarBytes = user?.avatarBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
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
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorOutlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Data Pengguna' : 'Tambah Pengguna Baru',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorSecondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_sync, size: 16, color: colorSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'Firestore',
                                style: GoogleFonts.workSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Avatar Picker
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 500,
                            maxHeight: 500,
                            imageQuality: 80,
                          );
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setModalState(() {
                              selectedAvatarBytes = bytes;
                            });
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: colorSecondary.withValues(alpha: 0.2),
                              backgroundImage: selectedAvatarBytes != null
                                  ? MemoryImage(selectedAvatarBytes!)
                                  : null,
                              child: selectedAvatarBytes == null
                                  ? Icon(
                                      Icons.person_add_alt_1,
                                      size: 32,
                                      color: colorSecondary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Nama Lengkap
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.workSans(color: colorOnSurface),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.badge_outlined, color: colorSecondary),
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input Email / ID Kasir
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.workSans(color: colorOnSurface),
                      decoration: InputDecoration(
                        labelText: 'Email / ID Kasir',
                        prefixIcon: Icon(Icons.email_outlined, color: colorSecondary),
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input Password
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: GoogleFonts.workSans(color: colorOnSurface),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, color: colorSecondary),
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input Nomor HP
                    TextField(
                      controller: noHpController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.workSans(color: colorOnSurface),
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        prefixIcon: Icon(Icons.phone_outlined, color: colorSecondary),
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input Asal Kota
                    TextField(
                      controller: cityController,
                      style: GoogleFonts.workSans(color: colorOnSurface),
                      decoration: InputDecoration(
                        labelText: 'Asal Kota',
                        prefixIcon: Icon(Icons.location_city_outlined, color: colorSecondary),
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Simpan / Update
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                        label: Text(
                          isEditing ? 'Simpan Perubahan' : 'Daftarkan Pengguna',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text;
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Email dan Password wajib diisi!'),
                                backgroundColor: colorError,
                              ),
                            );
                            return;
                          }

                          final userPayload = UserModelSQL(
                            id: user?.id,
                            nama: nameController.text.trim(),
                            email: email,
                            password: password,
                            nomor_hp: noHpController.text.trim(),
                            asalKota: cityController.text.trim(),
                            cashierId: email,
                            avatarBytes: selectedAvatarBytes,
                          );

                          if (isEditing) {
                            await DataBaseHelper().updateUser(userPayload);
                          } else {
                            await DataBaseHelper().registerUser(userPayload);
                          }

                          await UserDataStore.instance.reloadUserData();

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Data pengguna berhasil diperbarui di Firestore'
                                      : 'Pengguna baru berhasil ditambahkan ke Firestore',
                                ),
                                backgroundColor: colorSecondary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
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
}
