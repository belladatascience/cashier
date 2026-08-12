import 'package:flutter/material.dart';

// Widget HomeAbalAbalDay16 adalah halaman sederhana (StatelessWidget)
// yang digunakan untuk menampilkan data email dan password yang dikirim dari halaman form input.
class HomeAbalAbalDay16 extends StatelessWidget {
  // Constructor menerima parameter wajib 'email' dan opsional 'password'.
  const HomeAbalAbalDay16({
    super.key,
    required this.email,
    this.password,
    required String nama,
    required String nomorhp,
    required String datatambahan,
  });

  final String email;
  final String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Detail Day 16")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan email yang diterima
            Text(
              "Email: $email",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Menampilkan password yang diterima, jika null tampilkan pesan default
            Text(
              "Password: ${password ?? 'Tidak ada password'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
