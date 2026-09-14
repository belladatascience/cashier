import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveChatMessage {
  final String text;
  final bool isUser;
  final String time;

  LiveChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAgentTyping = false;

  late final List<LiveChatMessage> _messages = [
    LiveChatMessage(
      text: 'Halo! Selamat datang di Live Support Cloud BGA Co. Customer Care.',
      isUser: false,
      time: '10:30',
    ),
    LiveChatMessage(
      text:
          'Saya CS Agent Bot BGA Co. Silakan pilih topik kendala di bawah atau ketikkan pesan kendala kasir Anda.',
      isUser: false,
      time: '10:30',
    ),
  ];

  final List<String> _quickTopics = [
    'Sinkronisasi Firebase Cloud',
    'Printer POS Mati / Disconnected',
    'Cara Pembatalan Transaksi',
    'Lupa Kata Sandi Kasir',
    'Export Laporan ke Excel',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistoryFromFirebase();
  }

  Future<void> _loadChatHistoryFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('live_chats')
          .doc(user.uid)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .limit(25)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          return LiveChatMessage(
            text: data['text'] ?? '',
            isUser: data['isUser'] ?? false,
            time: data['time'] ?? '10:30',
          );
        }).toList();

        setState(() {
          _messages.addAll(loaded);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Firestore load chat notice: $e');
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveMessageToFirestore(LiveChatMessage msg) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('live_chats')
          .doc(user.uid)
          .collection('messages')
          .add({
        'text': msg.text,
        'isUser': msg.isUser,
        'time': msg.time,
        'uid': user.uid,
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore save message notice: $e');
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final userMsg = LiveChatMessage(
      text: text.trim(),
      isUser: true,
      time: timeStr,
    );

    setState(() {
      _messages.add(userMsg);
      _chatController.clear();
      _isAgentTyping = true;
    });

    _saveMessageToFirestore(userMsg);
    _scrollToBottom();

    // Generate responsive bot reply
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      String botReply =
          'Terima kasih atas informasi Anda. Pesan ini telah diteruskan ke tim teknis BGA Cloud. Apakah ada hal lain yang dapat kami bantu?';

      final lower = text.toLowerCase();
      if (lower.contains('cloud') || lower.contains('firebase') || lower.contains('sinkron')) {
        botReply =
            'Status Firebase Cloud: Terhubung secara realtime. Semua data staf, shift, dan transaksi disimpan otomatis di database Firestore.';
      } else if (lower.contains('printer') || lower.contains('cetak')) {
        botReply =
            'Untuk kendala printer POS:\n1. Pastikan Bluetooth perangkat aktif.\n2. Pastikan kertas thermal terpasang rapi.\n3. Matikan dan nyalakan ulang printer POS Anda.';
      } else if (lower.contains('batal') || lower.contains('void')) {
        botReply =
            'Untuk pembatalan transaksi, buka menu Transaksi -> Pilih No. Struk -> Tekan tombol Batalkan / Refund.';
      } else if (lower.contains('password') || lower.contains('lupa')) {
        botReply =
            'Anda dapat melakukan reset password melalui menu Ganti Kata Sandi di Pengaturan atau fitur Lupa Kata Sandi pada halaman Login via email resmi Firebase.';
      } else if (lower.contains('excel') || lower.contains('laporan')) {
        botReply =
            'Export Laporan Penjualan dapat diakses pada halaman Riwayat Transaksi dengan menekan tombol Export Excel di bagian atas.';
      }

      final botMsg = LiveChatMessage(
        text: botReply,
        isUser: false,
        time: timeStr,
      );

      setState(() {
        _isAgentTyping = false;
        _messages.add(botMsg);
      });

      _saveMessageToFirestore(botMsg);
      _scrollToBottom();
    });
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
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.secondaryColor.withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(
                        Icons.headset_mic,
                        color: theme.secondaryColor,
                        size: 20,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Support Cloud',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        'CS Agent • Online (Firebase Sync)',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: theme.dividerColor, height: 1.0),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Chat Message List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),

                // Typing Indicator
                if (_isAgentTyping)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BGA Support Agent sedang memproses jawaban...',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Quick Topics Chips
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  color: theme.surfaceContainerLow,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickTopics.map((topic) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(
                              topic,
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                            backgroundColor: theme.surfaceColor,
                            side: BorderSide(color: theme.dividerColor),
                            onPressed: () => _sendMessage(topic),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Chat Input Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lampiran tangkapan layar siap ditautkan...',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: theme.primaryColor,
                          ),
                          onSubmitted: _sendMessage,
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan pertanyaan kendala...',
                            hintStyle: GoogleFonts.workSans(
                              color: theme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: theme.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _sendMessage(_chatController.text),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
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

  Widget _buildMessageBubble(LiveChatMessage msg) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: msg.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.secondaryColor.withValues(alpha: 0.15),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: theme.secondaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? theme.primaryColor : theme.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: msg.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: msg.isUser ? Colors.white : theme.primaryColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.time,
                    style: GoogleFonts.workSans(
                      fontSize: 10,
                      color: msg.isUser
                          ? Colors.white70
                          : theme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 16, color: theme.primaryColor),
            ),
          ],
        ],
      ),
    );
  }
}
