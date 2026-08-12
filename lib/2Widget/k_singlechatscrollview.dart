import 'package:flutter/material.dart';

class SingleChildscrollviewDay8 extends StatelessWidget {
  const SingleChildscrollviewDay8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SingleChild day 8"),
        backgroundColor: Colors.green,
      ),
      // SingleChildScrollView Utama (Vertikal):
      // Digunakan untuk membungkus satu child widget (dalam hal ini Column) agar halamannya
      // bisa di-scroll secara vertikal ketika tinggi kontennya melebihi tinggi layar.
      body: SingleChildScrollView(
        // padding: Memberikan jarak (margin dalam) sebesar 16 piksel di semua sisi konten scroll.
        padding: EdgeInsets.all(16),
        // physics: Menentukan efek animasi saat melakukan scroll.
        // BouncingScrollPhysics memberikan efek pantulan khas iOS saat scroll mencapai ujung atas/bawah.
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // SingleChildScrollView Kedua (Horizontal):
            // Digunakan untuk membuat konten di dalamnya dapat di-scroll secara mendatar (kiri-kanan).
            SingleChildScrollView(
              // scrollDirection: Mengatur arah scroll menjadi horizontal (mendatar). Secara default adalah vertikal.
              scrollDirection: Axis.horizontal,
              // Menggunakan Row karena anak-anaknya diletakkan berdampingan secara horizontal.
              child: Row(
                children: [
                  Container(color: Colors.blue, height: 400, width: 400),
                  Container(color: Colors.black, height: 300, width: 300),
                  Container(color: Colors.cyan, height: 200, width: 200),
                ],
              ),
            ),
            // Widget tambahan di bawah SingleChildScrollView horizontal (dalam Column utama)
            Container(color: Colors.red, height: 400, width: 400),
            Container(color: Colors.yellow, height: 300, width: 300),
            Container(color: Colors.green, height: 200, width: 200),
          ],
        ),
      ),
    );
  }
}
