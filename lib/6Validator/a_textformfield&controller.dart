import 'package:cashier/6Validator/a_home_validator.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Widget TextFormFieldDay16 adalah halaman form validasi yang mendemonstrasikan
// penggunaan TextField, TextFormField, TextEditingController, FormState, dan validasi input.
class TextFormFieldDay16 extends StatefulWidget {
  const TextFormFieldDay16({super.key});

  @override
  State<TextFormFieldDay16> createState() => _TextFormFieldDay16State();
}

class _TextFormFieldDay16State extends State<TextFormFieldDay16> {
  // TextEditingController digunakan untuk mengontrol, membaca, dan memodifikasi teks di dalam form input.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // _formKey adalah kunci global (GlobalKey) yang unik untuk mengidentifikasi Form widget
  // serta melakukan validasi state Form tersebut.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // Menghubungkan Form dengan GlobalKey
        child: Column(
          children: [
            // TextField biasa tidak memiliki fitur validasi bawaan.
            // Setiap perubahan memicu setState untuk merender ulang UI (jika diperlukan).
            const Text("Dibawah ini TextField"),

            TextField(
              controller: emailController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            TextField(controller: emailController),
            TextField(controller: emailController),

            const Text("Dibawah ini TextFormField"),

            // TextFormField memiliki parameter validator untuk memvalidasi input secara langsung.
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) {
                // Aturan validasi email:
                // 1. Tidak boleh kosong.
                // 2. Harus mengandung karakter '@'.
                // 3. Harus diakhiri/mengandung domain 'ppkd.com'.
                if (value == null || value.isEmpty) {
                  return "Email tidak boleh kosong";
                } else if (!value.contains('@')) {
                  return "Email tidak valid";
                } else if (!value.contains('ppkd.com')) {
                  return "Email bukan email ppkd";
                }
                return null; // Mengembalikan null berarti input valid.
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              validator: (value) {
                // Aturan validasi password:
                // 1. Tidak boleh kosong.
                // 2. Minimal 8 karakter.
                if (value == null || value.isEmpty) {
                  return "Password tidak boleh kosong";
                } else if (value.length < 8) {
                  return "Password kurang dari 8 karakter";
                }
                return null;
              },
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Konfirmasi Password",
              ),
              validator: (value) {
                // Aturan validasi konfirmasi password:
                // 1. Tidak boleh kosong.
                // 2. Minimal 8 karakter.
                // 3. Harus sama nilainya dengan input passwordController.
                if (value == null || value.isEmpty) {
                  return "Konfirmasi Password tidak boleh kosong";
                } else if (value.length < 8) {
                  return "Konfirmasi Password kurang dari 8 karakter";
                } else if (value != passwordController.text) {
                  return "Password tidak cocok";
                }
                return null;
              },
            ),
            // Menampilkan email yang sedang diketik secara real-time
            Text(
              emailController.text,
              style: const TextStyle(color: Colors.red, fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                // Debugging di konsol
                print(emailController.text);
                print(passwordController.text);
                print(confirmPasswordController.text);

                // Memicu validasi seluruh TextFormField di dalam Form widget ini.
                if (_formKey.currentState!.validate()) {
                  // Jika validasi sukses, arahkan pengguna ke HomeAbalAbalDay16 dengan membawa parameter email & password.
                  context.push(
                    HomeAbalAbalDay16(
                      email: emailController.text,
                      password: passwordController.text,
                      nama: '',
                      nomorhp: '',
                      datatambahan: '',
                    ),
                  );
                } else {
                  // Jika gagal validasi, tampilkan dialog kesalahan dengan animasi Lottie.
                  print("Belum tervalidasi");
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.grey[100],
                      title: const Text("Info"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset("assets/animation/error.json"),
                          Text("${emailController.text} tidak valid"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop(); // Menutup dialog
                          },
                          child: const Text("Baiklah"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text("Tekan ini"),
            ),
          ],
        ),
      ),
    );
  }
}
