import 'package:flutter/material.dart';

class Tugas4Flutter extends StatelessWidget {
  const Tugas4Flutter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan & Riwayat Udara",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text(
            textAlign: TextAlign.center,
            "Laporan Kondisi Udara",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20, width: 20),
          buildFormLaporan(),
          SizedBox(height: 20, width: 20),
          Text(
            "Riwayat laporan Terakhir",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          buildRiwayatLaporan(),
        ],
      ),
    );
  }

  Column buildRiwayatLaporan() {
    return Column(
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
          ),
          child: ListTile(
            leading: Icon(Icons.warning, size: 50),
            title: Text(
              "Jakarta Pusat",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "AQI : 156 Tidak Sehat \nDilaporkan 5 Menit lalu",
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
          ),
          child: ListTile(
            leading: Icon(Icons.cloud, size: 50),
            title: Text(
              "Bandung Kota",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "AQI : 95 Sedang Dilaporkan 30   \nMenit Lalu",
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
          ),
          child: ListTile(
            leading: Icon(Icons.check_box, size: 50),
            title: Text(
              "Yogyakarta",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "AQI : 42 Baik Dilaporkan 1 hari \nlalu",
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
          ),
          child: ListTile(
            leading: Icon(Icons.trip_origin, size: 50),
            title: Text(
              "Semarang",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "AQI : 120 Sensitif Dilaporkan 5 Menit\nlalu",
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
      ],
    );
  }

  Column buildFormLaporan() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.map_sharp),
            labelText: "lokasi",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        SizedBox(height: 20, width: 20),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.air_sharp),
            labelText: "Skor AQI Teramati",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        SizedBox(height: 20, width: 20),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            labelText: "Nama Pelapor",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        SizedBox(height: 20, width: 20),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.list),

            labelText: "Catatan Tambahan ",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }
}
