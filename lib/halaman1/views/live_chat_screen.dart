import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
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
      text: 'Halo! Selamat datang di Live Chat BGA Co. Customer Care. ☕',
      isUser: false,
      time: '10:30',
    ),
    LiveChatMessage(
      text:
          'Saya CS Agent Bot BGA. Silakan pilih topik kendala di bawah atau ketikkan pertanyaan Anda.',
      isUser: false,
      time: '10:30',
    ),
  ];

  final List<String> _quickTopics = [
    'Printer POS Mati / Disconnected',
    'Cara Pembatalan Transaksi',
    'Lupa Kata Sandi Kasir',
    'Export Laporan ke Excel',
  ];

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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(
        LiveChatMessage(text: text.trim(), isUser: true, time: timeStr),
      );
      _chatController.clear();
      _isAgentTyping = true;
    });

    _scrollToBottom();

    // Simulate CS bot / agent response after 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      String botReply =
          'Terima kasih atas informasi Anda. Permintaan tiket Anda sedang diproses oleh tim spesialis teknis BGA Co. Apakah ada detail lain yang ingin disampaikan?';

      final lower = text.toLowerCase();
      if (lower.contains('printer') || lower.contains('cetak')) {
        botReply =
            'Untuk kendala printer POS:\n1. Pastikan Bluetooth tablet/HP sudah aktif.\n2. Cek apakah kertas struk habis atau tersangkut.\n3. Matikan dan hidupkan kembali printer POS Anda.';
      } else if (lower.contains('batal') || lower.contains('void')) {
        botReply =
            'Untuk pembatalan transaksi yang sudah lunas, silakan buka menu Riwayat Transaksi -> Pilih No. Invois -> Tekan tombol Opsi & lakukan instruksi pengembalian.';
      } else if (lower.contains('password') || lower.contains('lupa')) {
        botReply =
            'Reset kata sandi kasir dapat dilakukan oleh Akun Administrator atau menghubungi SPV Toko BGA Co.';
      } else if (lower.contains('excel') || lower.contains('laporan')) {
        botReply =
            'Export Laporan Penjualan Excel dapat diakses langsung pada halaman Riwayat Transaksi dengan menekan tombol [Export Excel] di pojok kanan atas.';
      }

      setState(() {
        _isAgentTyping = false;
        _messages.add(
          LiveChatMessage(text: botReply, isUser: false, time: timeStr),
        );
      });

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Chat CS Agent',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      'Online 24/7 • Responsif',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: const Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                // Chat List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
                ),

                // Agent Typing Indicator
                if (_isAgentTyping)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BGA Support Agent sedang mengetik...',
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
                                'Lampiran file/screenshot dibuka...',
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
