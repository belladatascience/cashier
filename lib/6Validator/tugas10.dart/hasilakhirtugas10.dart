import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResultPage extends StatelessWidget {
  final String nama;
  final String kota;

  const ResultPage({
    super.key,
    required this.nama,
    required this.kota,
    required String datatambahan,
    required String email,
    required String nomorhp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran Berhasil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animation/Trophy.json',
                height: 200,
              ), // Animasi Lottie
              const SizedBox(height: 20),
              Text(
                'Terima kasih, $nama dari $kota telah mendaftar.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
