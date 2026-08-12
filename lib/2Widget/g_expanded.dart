import 'package:flutter/material.dart';

/// Class [ExpandedDay6] mendemonstrasikan penggunaan widget [Expanded].
/// Expanded digunakan untuk memaksa widget anak mengisi sisa ruang yang tersedia
/// dalam tata letak fleksibel seperti [Row] (horizontal) dan [Column] (vertikal).
class ExpandedDay6 extends StatelessWidget {
  const ExpandedDay6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expanded day 6"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          // 1. Expanded di dalam Row (Horizontal)
          // Ketiga Container di dalam Row dibungkus dengan Expanded sehingga membagi
          // lebar layar secara merata (1/3 bagian masing-masing).
          Row(
            children: [
              Expanded(
                // flex menentukan porsi pembagian ruang. Default nilainya adalah 1.
                // Jika flex: 2 diaktifkan, maka container merah akan mengambil lebar 2x lipat dari container kuning/hijau.
                // flex: 2,
                child: Container(height: 200, color: Colors.red),
              ),
              Expanded(child: Container(height: 200, color: Colors.yellow)),
              Expanded(child: Container(height: 200, color: Colors.green)),
            ],
          ),
          SizedBox(height: 10), // Jarak pemisah setinggi 10 pixel
          // 2. Expanded di dalam Column (Vertikal)
          // Column mengisi tinggi layar. Sisa tinggi layar setelah dikurangi Row di atas dan SizedBox
          // akan dibagi di antara ketiga widget Expanded di bawah ini.
          Expanded(
            flex:
                2, // Container merah mengambil 2/4 (setengah) dari sisa tinggi layar yang tersedia
            child: Container(color: Colors.red),
          ),
          Expanded(
            flex: 1, // Container kuning mengambil 1/4 bagian
            child: Container(color: Colors.yellow),
          ),
          Expanded(
            flex: 1, // Container hijau mengambil 1/4 bagian
            child: Container(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
