import 'package:flutter/material.dart';

/// [HomeRouting2Day11] adalah widget halaman (screen) tujuan kedua.
/// Halaman ini menampilkan tombol sederhana untuk kembali ke halaman sebelumnya.
class HomeRouting2Day11 extends StatelessWidget {
  /// Konstruktor untuk [HomeRouting2Day11].
  /// [super.key] digunakan untuk meneruskan key ke constructor superclass [StatelessWidget].
  const HomeRouting2Day11({super.key});

  @override
  /// Method [build] berfungsi untuk menggambarkan struktur tampilan (UI) dari halaman ini.
  /// Method ini akan dijalankan ulang (rebuild) setiap kali Flutter perlu memperbarui tampilan.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Routing 2 Day 11"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigator.pop(context) digunakan untuk menghapus halaman saat ini
                // dari tumpukan (stack) navigasi dan kembali ke halaman sebelumnya.
                Navigator.pop(context);
              },
              child: Text("Balik / Pop"),
            ),
          ),
        ],
      ),
    );
  }
}
