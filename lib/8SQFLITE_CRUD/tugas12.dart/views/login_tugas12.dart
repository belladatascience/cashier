import 'package:cashier/8SQFLITE_CRUD/Tugas12.dart/database/databasehelper.dart';
import 'package:cashier/8SQFLITE_CRUD/Tugas12.dart/models/user_logintugas12.dart';
import 'package:cashier/4Input_widget/b_buttom_nav.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import package lottie

class LoginTugas12SQFLITE extends StatefulWidget {
  const LoginTugas12SQFLITE({super.key});

  @override
  State<LoginTugas12SQFLITE> createState() => _LoginTugas12SQFLITEState();
}

class _LoginTugas12SQFLITEState extends State<LoginTugas12SQFLITE> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController namaC = TextEditingController();
  final TextEditingController nomorHp = TextEditingController();
  final TextEditingController asalKota = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void register() async {
    final user = emailC.text.trim();
    final pass = passwordC.text;
    final nama = namaC.text;
    final noHp = nomorHp.text;
    final kota = asalKota.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi email dan password!')));
      return;
    }

    final pengguna = UserModelSQL(
      email: user,
      password: pass,
      nama: nama,
      nomor_hp: noHp,
      asalKota: kota,
    );

    bool success = await DBHelper().registerUser(pengguna);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar!')));
    }
  }

  void login() async {
    final user = emailC.text.trim();
    final pass = passwordC.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi email dan password!')));
      return;
    }

    final pengguna = await DBHelper().loginUser(user, pass);

    if (!mounted) return;

    if (pengguna != null) {
      context.pushAndRemoveAll(const BottomNavDay13());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal! Email atau Password salah.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color.fromARGB(255, 77, 46, 0);
    // ignore: unused_local_variable
    const socialBtnColor = Color(0xFF0A2E5C);

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CASHIER LATTEE',
          style: TextStyle(
            color: Color.fromARGB(255, 221, 176, 118),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          // fontSize: 28, fontWeight: FontWeight.bold
        ),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Lottie.asset("assets/animation/logocashier1.json", height: 250),
                // Input Nama Lengkap
                TextFormField(
                  controller: namaC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
                    hintText: 'Nama Lengkap',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Email
                TextFormField(
                  controller: emailC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Password
                TextFormField(
                  controller: passwordC,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Nomor HP
                TextFormField(
                  controller: nomorHp,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: Colors.white70,
                    ),
                    hintText: 'Nomor HP',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Asal Kota
                TextFormField(
                  controller: asalKota,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_city_outlined,
                      color: Colors.white70,
                    ),
                    hintText: 'Asal Kota',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 30),

                tombolLoginRegister(
                  primaryBgColor,
                  onPressed: () => login(),
                  teks: "Login",
                ),
                const SizedBox(height: 14),

                tombolLoginRegister(
                  primaryBgColor,
                  onPressed: () => register(),
                  teks: "Register",
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox tombolLoginRegister(
    Color primaryBgColor, {
    required void Function()? onPressed,
    required String teks,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
