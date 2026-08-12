import 'package:flutter/material.dart';

/// Class [CenterDay6] adalah sebuah StatelessWidget untuk mendemonstrasikan
/// penggunaan widget [Center] pada materi pembelajaran Flutter Day 6.
class CenterDay6 extends StatelessWidget {
  // Konstruktor konstan dengan super parameter key untuk performa yang optimal
  const CenterDay6({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar visual untuk halaman (seperti layar/body kosong)
    return Scaffold(
      // Center memposisikan widget anaknya (child) tepat di tengah area yang tersedia
      body: Center(
        // Text adalah widget dasar untuk menampilkan tulisan di layar
        child: Text("Tentu ini adalah batch 6"),
      ),
    );
  }
}
