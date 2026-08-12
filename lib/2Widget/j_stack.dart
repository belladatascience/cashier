import 'package:flutter/material.dart';

class StackDay8 extends StatelessWidget {
  const StackDay8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stack day 8"), backgroundColor: Colors.green),
      body: Column(
        children: [
          // Stack 1: Menumpuk widget secara berurutan dari paling bawah ke paling atas.
          // Widget pertama dalam list children akan berada di paling bawah/belakang,
          // sedangkan widget terakhir akan berada di paling atas/depan.
          Stack(
            // alignment menentukan posisi penumpukan children. Di sini diatur ke tengah.
            alignment: AlignmentGeometry.center,

            children: [
              // Container merah berada di paling belakang (lapisan pertama)
              Container(color: Colors.red, height: 400, width: 400),
              // Container kuning menumpuk di atas container merah (lapisan kedua)
              Container(color: Colors.yellow, height: 300, width: 300),
              // Container hijau menumpuk di atas container kuning (lapisan teratas/depan)
              Container(color: Colors.green, height: 200, width: 200),
            ],
          ),
          // Stack 2: Menggunakan Clip.none dan Positioned untuk menempatkan widget di luar area Stack.
          Stack(
            alignment: AlignmentGeometry.center,
            // clipBehavior: Clip.none digunakan agar widget yang diposisikan di luar batas
            // area Stack (menggunakan koordinat negatif) tidak terpotong (clipped).
            clipBehavior: Clip.none,
            children: [
              // Container merah sebagai dasar (lapisan paling belakang)
              Container(color: Colors.red, height: 200, width: 200),
              // Container kuning menumpuk di atas merah
              Container(color: Colors.yellow, height: 100, width: 100),
              // Positioned digunakan untuk mengatur posisi koordinat child secara spesifik
              // relatif terhadap sisi-sisi Stack (top, bottom, left, right).
              Positioned(
                // bottom: -20 menggeser container hijau keluar batas bawah Stack sebanyak 20 piksel.
                bottom: -20,
                child: Container(color: Colors.green, height: 50, width: 50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
