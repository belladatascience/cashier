import 'package:cashier/4Input_widget/d_drawer.dart';
import 'package:cashier/4Input_widget/tugas7.dart/finaltugas7.dart';
import 'package:cashier/7Shared_preference/service/preference_handler.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';

// Halaman Login Day 17 (StatefulWidget untuk mengelola controller input teks dan interaksi user).
class LoginDay17 extends StatefulWidget {
  const LoginDay17({super.key});

  @override
  State<LoginDay17> createState() => _LoginDay17State();
}

class _LoginDay17State extends State<LoginDay17> {
  // Controller untuk membaca dan mengontrol isi field input email.
  final TextEditingController emailC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Warna latar belakang utama (Dark Blue) & warna tombol sosial media.
    const primaryBgColor = Color(0xFF00224D);
    const socialBtnColor = Color(0xFF0A2E5C);

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            // Aksi tombol kembali (jika diperlukan)
          },
        ),
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Judul & Sub-judul halaman login
              const Text(
                'Hello Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome Back Please Sign in Again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // Input Email
              TextField(
                controller: emailC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Input Password
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Login Utama
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 1. Menyimpan status login menjadi true di SharedPreferences lokal storage.
                    PreferenceHandler.setLogin(true);

                    // 2. Berpindah halaman ke BottomNavDay13 menggunakan extension navigator (context.push).
                    context.push(const Tugas7flutter());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Pembatas / Divider "Or"
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Or',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                ],
              ),

              const SizedBox(height: 30),

              // Tombol Login via Facebook
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigasi alternatif ke halaman DrawerDay13
                    context.push(const DrawerDay13());
                  },
                  icon: Image.asset('assets/images/fb.png', cacheHeight: 30),
                  label: const Text(
                    'Facebook',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: socialBtnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Login via Gmail
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/images/gg.png', cacheHeight: 30),
                  label: const Text(
                    'Gmail',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: socialBtnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer: Already have an account ? Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already Have An Account ? ',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Aksi navigasi ke halaman Sign In jika ada
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
