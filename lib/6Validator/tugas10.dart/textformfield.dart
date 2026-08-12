import 'package:cashier/6Validator/tugas10.dart/hasilakhirtugas10.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Widget TextFormFieldDay16 adalah halaman form validasi yang mendemonstrasikan
// penggunaan TextField, TextFormField, TextEditingController, FormState, dan validasi input.
class TextFormFieldtugas10 extends StatefulWidget {
  const TextFormFieldtugas10({super.key});

  @override
  State<TextFormFieldtugas10> createState() => _TextFormFieldtugas10();
}

class _TextFormFieldtugas10 extends State<TextFormFieldtugas10> {
  final TextEditingController nama = TextEditingController();

  // TextEditingController digunakan untuk mengontrol, membaca, dan memodifikasi teks di dalam form input.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController kota = TextEditingController();
  final TextEditingController nomorHp = TextEditingController();
  final TextEditingController dataTambahan = TextEditingController();

  // _formKey adalah kunci global (GlobalKey) yang unik untuk mengidentifikasi Form widget
  // serta melakukan validasi state Form tersebut.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // Menghubungkan Form dengan GlobalKey
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // TextField biasa tidak memiliki fitur validasi bawaan.
            // Setiap perubahan memicu setState untuk merender ulang UI (jika diperlukan).
            // const Text("Register"),
            const SizedBox(height: 12),
            TextFormField(
              controller: nama,
              decoration: const InputDecoration(labelText: "Nama"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Nama tidak boleh kosong";
                } else if (!value.contains('')) {}
                return null;
              },
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email tidak boleh kosong";
                } else if (!value.contains('@')) {
                  return "Email harus mengandung @";
                } else if (!value.contains('ppkd.com')) {
                  return "Email harus menggunakan domain ppkd.com";
                }
                return null;
              },
            ),

            // const SizedBox(height: 12),
            // const SizedBox(height: 12),
            const SizedBox(height: 12),
            TextFormField(
              controller: nomorHp,
              decoration: const InputDecoration(labelText: "Nomor HP"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: dataTambahan,
              decoration: const InputDecoration(labelText: "Data Tambahan"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Data Tambahan tidak boleh kosong";
                }
                return null;
              },
            ),
            TextFormField(
              controller: kota,
              decoration: const InputDecoration(labelText: "Kota"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Kota tidak boleh kosong";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // const Text("Dibawah ini TextFormField"),
            const SizedBox(height: 12),

            // TextFormField memiliki parameter validator untuk memvalidasi input secara langsung
            ElevatedButton(
              onPressed: () {
                // Debugging di konsol
                print(emailController.text);
                print(passwordController.text);
                print(kota.text);

                // Memicu validasi seluruh TextFormField di dalam Form widget ini.
                if (_formKey.currentState!.validate()) {
                  // Jika validasi sukses, arahkan pengguna ke HomeAbalAbalDay16 dengan membawa parameter email & password.
                  context.push(
                    ResultPage(
                      nama: nama.text,
                      email: emailController.text,
                      nomorhp: nomorHp.text,
                      kota: kota.text,
                      datatambahan: dataTambahan.text,
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
                          Text("${nama.text} tidak valid"),
                          Text("${emailController.text} tidak valid"),
                          Text("${dataTambahan.text} tidak valid"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop();
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
