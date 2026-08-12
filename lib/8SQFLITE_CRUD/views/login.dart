import 'package:cashier/4Input_widget/b_buttom_nav.dart';
import 'package:cashier/4Input_widget/d_drawer.dart';
import 'package:cashier/8SQFLITE_CRUD/database/db_helper.dart';
import 'package:cashier/8SQFLITE_CRUD/models/user_login.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';
// import 'package:ppkd_b7/day_13/bottom_nav.dart';
// import 'package:ppkd_b7/day_13/drawer.dart';
// import 'package:ppkd_b7/day_18/database/db_helper.dart';
// import 'package:ppkd_b7/day_18/models/user_login_model.dart';
// import 'package:ppkd_b7/extension/navigator.dart';

// Halaman Login & Register Day 18 menggunakan SQLite (sqflite) untuk otentikasi lokal.
class LoginDay18SQFLITE extends StatefulWidget {
  const LoginDay18SQFLITE({super.key});

  @override
  State<LoginDay18SQFLITE> createState() => _LoginDay18SQFLITEState();
}

class _LoginDay18SQFLITEState extends State<LoginDay18SQFLITE> {
  // Controller untuk menangani input email dan password dari TextField.
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  // Global key untuk mengidentifikasi dan memvalidasi Form.
  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk mendaftarkan akun pengguna baru ke database SQLite.
  void register() async {
    final user = emailC.text.trim();
    final pass = passwordC.text;

    // Validasi dasar bahwa inputan tidak boleh kosong.
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi semua field!')));
      return;
    }

    // Membuat objek UserModelSQL dari input form.
    final pengguna = UserModelSQL(email: user, password: pass);

    // Menyimpan data pengguna ke database SQLite melalui DBHelper.
    bool success = await DBHelper().registerUser(pengguna);

    if (!mounted) return;

    // Menampilkan notifikasi SnackBar sesuai hasil pendaftaran.
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar!')));
    }
  }

  // Fungsi untuk memverifikasi login pengguna menggunakan data di SQLite.
  void login() async {
    final user = emailC.text.trim();
    final pass = passwordC.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi semua field!')));
      return;
    }

    // Memeriksa pencocokan kredensial email & password di database.
    final pengguna = await DBHelper().loginUser(user, pass);

    if (!mounted) return;

    if (pengguna != null) {
      // Jika berhasil login, navigasi ke halaman utama (BottomNavDay13).
      context.pushAndRemoveAll(const BottomNavDay13());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal! email atau Password salah.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna tema halaman (Dark Blue).
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
            // Aksi tombol kembali
          },
        ),
        title: const Text(
          'Login (SQLite)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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

                // Input Field: Email
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email tidak boleh kosong";
                    } else if (!value.contains('@')) {
                      return "Email tidak valid";
                    }
                    return null; // Input valid
                  },
                  controller: emailC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
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

                // Input Field: Password
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password tidak boleh kosong";
                    } else if (value.length < 8) {
                      return "Password kurang dari 8 karakter";
                    }
                    return null; // Input valid
                  },
                  controller: passwordC,
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

                // Tombol Login
                tombolLoginRegister(
                  primaryBgColor,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  teks: "Login",
                ),
                const SizedBox(height: 14),

                // Tombol Register
                tombolLoginRegister(
                  primaryBgColor,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      register();
                    }
                  },
                  teks: "Register",
                ),

                const SizedBox(height: 30),

                // Divider "Or"
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Colors.white24, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Or',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white24, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Tombol Login via Facebook
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(const DrawerDay13());
                    },
                    icon: Image.asset('assets/images/Fb.png', cacheHeight: 30),
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
                    icon: Image.asset(
                      'assets/images/google.png',
                      cacheHeight: 30,
                    ),
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
                      onTap: () {},
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
      ),
    );
  }

  // Helper widget kustom untuk membuat tombol bersuara rounded (Reusable Login/Register button)
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
          elevation: 0,
        ),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
