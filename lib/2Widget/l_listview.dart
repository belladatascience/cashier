import 'package:flutter/material.dart';

class ListViewDay8 extends StatelessWidget {
  const ListViewDay8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ListViewday 8"),
        backgroundColor: Colors.green,
      ),
      body:
          // === Versi 4: ListView.separated ===
          // Memungkinkan kita membuat daftar item scrollable yang dilengkapi dengan pemisah (separator)
          // di antara setiap item secara otomatis. Sangat baik untuk performa list yang panjang.
          ListView.separated(
            itemCount: 100, // Jumlah item sebanyak 100
            // separatorBuilder digunakan untuk membuat widget pemisah di antara item list
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                height: 100,
              ); // Garis horizontal pemisah dengan tinggi area 100 piksel
            },
            // itemBuilder dipanggil untuk membuat setiap item list berdasarkan indeksnya
            itemBuilder: (BuildContext context, int index) {
              // ListTile adalah widget bawaan Flutter yang sangat cocok untuk item list standar
              return ListTile(
                leading: Text(
                  "${index + 1}",
                ), // Widget di ujung kiri (biasanya angka, ikon, atau avatar)
                title: Text("Nama : ${index + 1}"), // Teks utama/judul item
                subtitle: Text(
                  "Email : ${index + 1}",
                ), // Teks tambahan di bawah judul
                trailing: Icon(
                  Icons.arrow_forward,
                ), // Widget di ujung kanan (biasanya tombol tindakan atau ikon panah)
              );
            },
          ),
      // === Versi 3: ListView.builder (Di-comment out) ===
      // Digunakan untuk merender list item secara dinamis pada saat di-scroll tanpa pembatas bawaan.
      // ListView.builder(
      //   itemCount: 100,
      //   itemBuilder: (BuildContext context, int index) {
      //     return Column(
      //       children: [
      //         Container(
      //           width: double.infinity,
      //           color: Colors.red,
      //           child: Text(
      //             "data $index",
      //             style: TextStyle(color: Colors.white, fontSize: 20),
      //           ),
      //         ),
      //         SizedBox(height: 10),
      //       ],
      //     );
      //   },
      // ),
      // === Versi 2: ListView.custom (Di-comment out) ===
      // Memberikan kontrol lebih detail atas delegasi anak (child delegate), berguna untuk kasus list yang sangat khusus.
      // ListView.custom(
      //   childrenDelegate: SliverChildBuilderDelegate(childCount: 100, (
      //     context,
      //     index,
      //   ) {
      //     return Column(
      //       children: [
      //         Container(
      //           width: double.infinity,
      //           color: Colors.red,
      //           child: Text(
      //             "data $index",
      //             style: TextStyle(color: Colors.white, fontSize: 20),
      //           ),
      //         ),
      //         SizedBox(height: 10),
      //       ],
      //     );
      //   }),
      // ),
      // === Versi 1: ListView Statis (Di-comment out) ===
      // Menggunakan widget ListView biasa dengan daftar children statis.
      // Cocok untuk halaman setelan (settings) atau daftar dengan jumlah item sedikit dan tetap.
      // ListView(
      //   children: [
      //     Container(color: Colors.blue, height: 400, width: 400),
      //     Container(color: Colors.black, height: 300, width: 300),
      //     Container(color: Colors.cyan, height: 200, width: 200),
      //     Container(color: Colors.blue, height: 400, width: 400),
      //     Container(color: Colors.black, height: 300, width: 300),
      //     Container(color: Colors.cyan, height: 200, width: 200),
      //   ],
      // ),
    );
  }
}
