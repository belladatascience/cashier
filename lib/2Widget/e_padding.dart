import 'package:flutter/material.dart';

/// Class [ContohPaddingDay6] mendemonstrasikan penggunaan widget [Padding]
/// untuk memberikan ruang kosong (jarak) di sekitar widget anak.
class ContohPaddingDay6 extends StatelessWidget {
  const ContohPaddingDay6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
          255,
          171,
          64,
          1,
        ), // Warna AppBar menggunakan format RGBA
        title: Text("Profil Saya"),
        centerTitle:
            true, // Menempatkan judul AppBar di tengah secara horizontal
        actions: [
          Text("1"),
          Text("2"),
        ], // Widget di sisi kanan AppBar (biasanya tombol aksi)
        leading: Icon(
          Icons.people,
        ), // Widget di sisi kiri AppBar (biasanya tombol menu/kembali)
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.start, // Menyusun children dari atas ke bawah
        // mainAxisSize: MainAxisSize.Max,
        spacing:
            20, // Menambahkan jarak konstan antar children di dalam Column (fitur Flutter baru)
        children: [
          // Padding digunakan untuk membungkus widget lain dan memberikan jarak luar/dalam
          Padding(
            // Berbagai metode untuk mengatur nilai padding (EdgeInsets):
            // - EdgeInsets.all(24.0) -> Jarak sama di semua sisi (atas, bawah, kiri, kanan)
            // - EdgeInsets.only(left: 24.0) -> Jarak khusus di sisi tertentu saja (contoh: kiri saja)
            // - EdgeInsets.symmetric(horizontal: 20) -> Jarak simetris secara horizontal (kiri-kanan) atau vertical (atas-bawah)
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Text(
              "Seorang peserta pelatihan yang sedang mendalami Flutter di PPKD. "
              "Saya sangat antusias untuk belajar dan mengembangkan "
              "kemampuan saya dalam pengembangan aplikasi mobile. "
              "Flutter adalah framework yang sangat menarik "
              "karena memungkinkan pengembangan aplikasi lintas platform. "
              "Saya berharap dapat menguasai Flutter dengan baik "
              "dan menciptakan aplikasi yang bermanfaat. "
              "Selain itu, saya juga ingin berkontribusi "
              "dalam komunitas pengembang Flutter di masa depan.",
              textAlign: TextAlign.center, // Perataan teks di tengah paragraf
            ),
          ),
        ],
      ),
    );
  }
}
