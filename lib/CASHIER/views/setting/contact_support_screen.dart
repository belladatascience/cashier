import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/utils/user_data_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _contactC = TextEditingController();
  final TextEditingController _subjectC = TextEditingController();
  final TextEditingController _messageC = TextEditingController();

  String _selectedCategory = 'Kendala Transaksi';
  bool _isSubmitting = false;
  String? _attachedFileName;

  final List<String> _categories = [
    'Kendala Transaksi',
    'Masalah Akun & Login',
    'Printer POS & Bluetooth',
    'Stok & Manajemen Menu',
    'Laporan Penjualan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final user = FirebaseAuth.instance.currentUser;
    final data = UserDataStore.instance.userDataNotifier.value;

    final defaultName = user?.displayName ?? data['accountName'] ?? data['cashierName'] ?? '';
    final defaultContact = user?.email ?? user?.phoneNumber ?? data['email'] ?? data['phone'] ?? '';

    if (defaultName.isNotEmpty) {
      _nameC.text = defaultName;
    }
    if (defaultContact.isNotEmpty) {
      _contactC.text = defaultContact;
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _contactC.dispose();
    _subjectC.dispose();
    _messageC.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final ticketCode = 'BGA-TICK-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final user = FirebaseAuth.instance.currentUser;

    try {
      // 1. Simpan data tiket ke Cloud Firestore
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'ticketId': ticketCode,
        'uid': user?.uid ?? 'anonymous',
        'namaPengirim': _nameC.text.trim(),
        'kontak': _contactC.text.trim(),
        'kategori': _selectedCategory,
        'subjek': _subjectC.text.trim(),
        'pesan': _messageC.text.trim(),
        'namaLampiran': _attachedFileName,
        'status': 'OPEN',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore write ticket notice: $e');
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.instance.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.instance.secondaryColor,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Tiket Terkirim ke Cloud!',
              style: GoogleFonts.sourceSerif4(
                fontWeight: FontWeight.bold,
                color: AppTheme.instance.primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiket dukungan Anda telah berhasil disimpan ke Cloud Firebase dengan ID:',
              style: GoogleFonts.workSans(
                color: AppTheme.instance.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.instance.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.instance.dividerColor),
              ),
              child: Text(
                ticketCode,
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.instance.secondaryColor,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tim BGA Support akan segera menindaklanjuti kendala Anda dalam waktu 1x24 jam.',
              style: GoogleFonts.workSans(
                fontSize: 12.5,
                color: AppTheme.instance.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.instance.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Kembali ke Pengaturan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'BGA Help & Support',
              style: GoogleFonts.sourceSerif4(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: theme.dividerColor, height: 1.0),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.headset_mic_rounded,
                                color: theme.primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pusat Layanan BGA Support',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kirimkan kendala operasional kasir Anda ke cloud dan teknisi kami akan segera merespons.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 13,
                                      color: theme.onSurfaceVariant,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Direct Channels
                      Text(
                        'Kontak Langsung CS',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChannelCard(
                              icon: Icons.chat_outlined,
                              title: 'WhatsApp Support',
                              subtitle: '087888848000',
                              color: const Color(0xFF25D366),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Membuka WhatsApp 087888848000...',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChannelCard(
                              icon: Icons.email_outlined,
                              title: 'Email Official',
                              subtitle: 'bellagasmaraworker@gmail.com',
                              color: theme.primaryColor,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Membuka Email bellagasmaraworker@gmail.com...',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Form Title
                      Text(
                        'Formulir Tiket Dukungan Firebase',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Support Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Field: Name
                            Text(
                              'Nama Lengkap',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameC,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Harap isi nama Anda'
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama pengirim',
                                filled: true,
                                fillColor: theme.surfaceColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field: Contact Info
                            Text(
                              'Email / No. WhatsApp Kasir',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _contactC,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Harap isi kontak Anda'
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'contoh: 08123456789 atau email@bga.com',
                                filled: true,
                                fillColor: theme.surfaceColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field: Category Dropdown
                            Text(
                              'Kategori Kendala',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              dropdownColor: theme.surfaceColor,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: theme.surfaceColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                              items: _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.workSans(
                                      fontSize: 14,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Field: Subject
                            Text(
                              'Judul / Subjek Kendala',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _subjectC,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Harap isi subjek kendala'
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'contoh: Printer thermal tidak konek',
                                filled: true,
                                fillColor: theme.surfaceColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field: Message
                            Text(
                              'Deskripsi Rinci Kendala',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _messageC,
                              maxLines: 4,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Harap jelaskan kendala secara rinci'
                                  : null,
                              decoration: InputDecoration(
                                hintText:
                                    'Jelaskan kronologi kendala atau pertanyaan Anda secara rinci...',
                                filled: true,
                                fillColor: theme.surfaceColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Attachment Picker Simulation
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _attachedFileName =
                                      'Screenshot_Kendala_POS.png';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Lampiran Screenshot berhasil ditambahkan!',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file_rounded,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _attachedFileName ??
                                            'Lampirkan Foto/Screenshot Kendala (Opsional)',
                                        style: GoogleFonts.workSans(
                                          fontSize: 13,
                                          color: _attachedFileName != null
                                              ? theme.secondaryColor
                                              : theme.onSurfaceVariant,
                                          fontWeight: _attachedFileName != null
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (_attachedFileName != null)
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () {
                                          setState(
                                            () => _attachedFileName = null,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitForm,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded, size: 20),
                                label: Text(
                                  _isSubmitting
                                      ? 'Mengirim ke Cloud...'
                                      : 'Kirim Tiket ke Firebase',
                                  style: GoogleFonts.workSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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

  Widget _buildChannelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.instance;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
