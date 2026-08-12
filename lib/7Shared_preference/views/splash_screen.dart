import 'package:cashier/4Input_widget/tugas7.dart/finaltugas7.dart';
import 'package:cashier/7Shared_preference/service/preference_handler.dart';
import 'package:cashier/7Shared_preference/views/login.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:ppkd_b7/day_13/bottom_nav.dart';
// import 'package:ppkd_b7/day_17/service/preference_handler.dart';
// import 'package:ppkd_b7/day_17/views/login_day_17.dart';
// import 'package:ppkd_b7/extension/navigator.dart';

// Widget SplashScreenDay17 berupa StatefulWidget untuk menangani proses async (delay & pengecekan session login saat awal aplikasi dibuka).
class SplashScreenDay17 extends StatefulWidget {
  const SplashScreenDay17({super.key});

  @override
  State<SplashScreenDay17> createState() => _SplashScreenDay17State();
}

class _SplashScreenDay17State extends State<SplashScreenDay17> {
  @override
  void initState() {
    super.initState();
    // Memanggil fungsi goToLogin() segera setelah widget diinisialisasi.
    goToLogin();
  }

  // Fungsi untuk menangani alur perpindahan halaman dari splash screen.
  void goToLogin() async {
    // Memberikan penundaan (delay) selama 3 detik untuk menampilkan animasi splash screen.
    await Future.delayed(const Duration(seconds: 3));

    // Mengecek status login pengguna dari SharedPreferences melalui PreferenceHandler.
    if (PreferenceHandler.isLogin == true) {
      // Jika pengguna sudah login, arahkan langsung ke halaman utama (BottomNavDay13).
      context.push(const Tugas7flutter());
    } else {
      // Jika belum login, arahkan ke halaman LoginDay17.
      context.push(const LoginDay17());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan animasi Lottie di tengah layar sebagai visual splash screen.
      body: Center(child: Lottie.asset("assets/animation/logocashier1.json")),
    );
  }
}
