import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
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

    await Future.delayed(const Duration(milliseconds: 1200));

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
              'Pesan Terkirim!',
              style: GoogleFonts.sourceSerif4(
                fontWeight: FontWeight.bold,
                color: AppTheme.instance.primaryColor,
              ),
            ),
          ],
        ),
        content: Text(
          'Tiket dukungan Anda telah berhasil dibuat. Tim BGA Support akan menghubungi Anda dalam waktu 1x24 jam melalui WhatsApp/Email.',
          style: GoogleFonts.workSans(
            color: AppTheme.instance.onSurfaceVariant,
          ),
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
            child: const Text('Kembali ke Help Center'),
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
              'Contact Support',
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
                                    'Kirimkan kendala operasional kasir Anda dan tim teknisi kami akan segera merespons.',
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
                        'Formulir Tiket Dukungan',
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

                            // Field: Contact (Email/No. HP)
                            Text(
                              'Nomor WhatsApp / Email',
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
                                  ? 'Harap isi kontak WhatsApp / Email'
                                  : null,
                              decoration: InputDecoration(
                                hintText:
                                    'misal: 08123456789 atau kasir@gmail.com',
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

                            // Field: Category
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
                              items: _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.workSans(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
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
                            ),
                            const SizedBox(height: 16),

                            // Field: Subject
                            Text(
                              'Subjek Kendala',
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
                                  ? 'Harap isi subjek pesan'
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Ringkasan kendala yang dialami',
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

                            // Field: Detail Message
                            Text(
                              'Detail Pesan Kendala',
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
                                      ? 'Mengirim Pesan...'
                                      : 'Kirim Tiket Dukungan',
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
