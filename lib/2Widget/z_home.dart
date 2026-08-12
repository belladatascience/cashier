import 'package:cashier/2Widget/z_home2.dart';
import 'package:cashier/2widget/p_save_button.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';

/// [HomeRoutingDay11] adalah widget halaman (screen) tujuan pertama.
/// Halaman ini menunjukkan bagaimana cara kembali ke halaman sebelumnya (Pop)
/// dan berpindah halaman sambil menghapus semua riwayat tumpukan navigasi (PushAndRemoveAll).
class HomeRoutingDay11 extends StatelessWidget {
  /// Konstruktor untuk [HomeRoutingDay11].
  /// [super.key] digunakan untuk meneruskan key ke constructor superclass [StatelessWidget].
  const HomeRoutingDay11({super.key});

  @override
  /// Method [build] berfungsi untuk menggambarkan struktur tampilan (UI) dari halaman ini.
  /// Method ini akan dijalankan ulang (rebuild) setiap kali Flutter perlu memperbarui tampilan.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Routing Day 11"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigator.pop(context) digunakan untuk kembali ke halaman sebelumnya
                // dengan cara menghapus (pop) halaman saat ini dari tumpukan (stack) navigasi.
                Navigator.pop(context);
              },
              child: Text("Balik / Pop"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // context.pushAndRemoveAll berasal dari extension navigator.dart.
                // Fungsi ini membuka halaman HomeRouting2Day11 dan menghapus seluruh
                // tumpukan halaman yang ada sebelumnya (sehingga user tidak bisa menekan tombol back ke halaman lama).
                context.pushAndRemoveAll(HomeRouting2Day11());
              },
              child: Text("PushRemoveUntil"),
            ),
          ),
          SaveButton(),
        ],
      ),
    );
  }
}
