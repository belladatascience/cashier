import 'package:flutter/material.dart';

/// Class [SpacerDay6] mendemonstrasikan penggunaan widget [Spacer].
/// [Spacer] menciptakan ruang kosong yang fleksibel dan dapat diubah ukurannya
/// untuk memisahkan widget-widget lain di dalam tata letak fleksibel ([Row] atau [Column]).
class SpacerDay6 extends StatelessWidget {
  const SpacerDay6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spacer day 6"),
        backgroundColor: const Color.fromARGB(255, 15, 206, 219),
      ),
      body: Column(
        children: [
          // 1. Menggunakan Spacer di dalam Row (Horizontal)
          // Spacer di sini menyisipkan ruang kosong di antara container merah, kuning, dan hijau.
          // Secara internal, Spacer adalah widget Expanded kosong dengan flex default = 1.
          Row(
            children: [
              Expanded(
                // flex: 2,
                child: Container(height: 200, color: Colors.red),
              ),
              Spacer(), // Mengambil sisa ruang kosong secara merata untuk memisahkan container merah dan kuning
              Expanded(child: Container(height: 200, color: Colors.yellow)),
              Spacer(), // Mengambil sisa ruang kosong secara merata untuk memisahkan container kuning dan hijau
              Expanded(child: Container(height: 200, color: Colors.green)),
            ],
          ),
          Center(child: Text("Haloha")),
          SizedBox(height: 10),

          // 2. Menggunakan Expanded di dalam Column (Vertikal)
          Expanded(flex: 2, child: Container(color: Colors.red)),
          Expanded(child: Container(color: Colors.yellow)),
          Expanded(child: Container(color: Colors.green)),
        ],
      ),
    );
  }
}
