import 'package:flutter/material.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';

// ShowImageDay10 adalah StatefulWidget karena status tampilan gambar (tampil/sembunyi)
// akan berubah saat pengguna menekan tombol.
class ShowImageDay10 extends StatefulWidget {
  const ShowImageDay10({super.key});

  @override
  State<ShowImageDay10> createState() => _ShowImageDay10State();
}

class _ShowImageDay10State extends State<ShowImageDay10> {
  // Variabel state boolean untuk mengontrol apakah gambar dari internet ditampilkan atau disembunyikan
  bool showImage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Day 10"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          // 1. Menampilkan gambar lokal menggunakan Image.asset
          // Catatan pembelajaran: Gambar ini harus didaftarkan terlebih dahulu di pubspec.yaml pada bagian assets.
          Image.asset("assets/images/logocashier.jpg", height: 200),

          // 2. Ternary Operator Pertama
          // Jika showImage bernilai true, tampilkan Image.network (gambar dari internet).
          // Jika showImage bernilai false, tampilkan Container berwarna biru berukuran 200x200.
          showImage
              ? Image.network(
                  "https://img-global.cpcdn.com/recipes/6c968b8ee6761419/1280x1280sq80/photo.webp",
                  height: 200,
                )
              : Container(color: Colors.blue, height: 200, width: 200),

          // 3. Ternary Operator Kedua (Dengan efek Shimmer)
          // Jika showImage bernilai true, tampilkan Image.network.
          // Jika showImage bernilai false, tampilkan Container abu-abu dengan efek animasi kilauan (loading shimmer).
          showImage
              ? Image.network(
                  "https://img-global.cpcdn.com/recipes/6c968b8ee6761419/1280x1280sq80/photo.webp",
                  height: 200,
                )
              : Container(color: Colors.grey[600], height: 200, width: 200),

          // 4. Tombol untuk menyalakan/mematikan state showImage
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // Warna tombol berubah dinamis: Biru jika gambar tampil, Merah jika gambar disembunyikan
              backgroundColor: showImage ? Colors.blue : Colors.red,
            ),
            onPressed: () {
              // Memicu rebuild UI agar tampilan layar diperbarui
              setState(() {});

              // Membalikkan nilai boolean showImage (true menjadi false, false menjadi true)
              showImage = !showImage;

              // Memunculkan pesan singkat (SnackBar) di bagian bawah layar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !showImage ? "Gambar disembunyikan" : "Gambar ditampilkan",
                  ),
                ),
              );
            },
            child: Text(
              // Teks tombol berubah dinamis sesuai status showImage
              showImage ? "Sembunyikan" : "Tampilkan",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
