import 'package:cashier/5ListOfMap/tugas8.dart/a_model.dart';
import 'package:flutter/material.dart';

class ListOfModelDay15 extends StatelessWidget {
  ListOfModelDay15({super.key});

  List<BuahModel> dataProduk = [
    BuahModel(nama: "Apel", harga: "25000", asal: "Jepang"),
    BuahModel(nama: "Pisang", harga: "15000", asal: "Indonesia"),
    BuahModel(nama: "Jeruk", harga: "20000", asal: "Spanyol"),
    BuahModel(nama: "Mangga", harga: "30000", asal: "India"),
    BuahModel(nama: "Anggur", harga: "40000", asal: "Italia"),
    BuahModel(nama: "Semangka", harga: "18000", asal: "Brazil"),
    BuahModel(nama: "Melon", harga: "22000", asal: "Australia"),
    BuahModel(nama: "Kiwi", harga: "50000", asal: "Selandia Baru"),
    BuahModel(nama: "Nanas", harga: "12000", asal: "Filipina"),
    BuahModel(nama: "Stroberi", harga: "45000", asal: "Amerika Serikat"),
    BuahModel(nama: "Durian", harga: "60000", asal: "Thailand"),
    BuahModel(nama: "Rambutan", harga: "25000", asal: "Malaysia"),
    BuahModel(nama: "Pepaya", harga: "10000", asal: "Meksiko"),
    BuahModel(nama: "Jambu", harga: "15000", asal: "Vietnam"),
    BuahModel(nama: "Leci", harga: "35000", asal: "Cina"),
    BuahModel(nama: "Delima", harga: "30000", asal: "Iran"),
    BuahModel(nama: "Sirsak", harga: "20000", asal: "Karibia"),
    BuahModel(nama: "Ceri", harga: "55000", asal: "Turki"),
    BuahModel(nama: "Alpukat", harga: "40000", asal: "Meksiko"),
    BuahModel(nama: "Blueberry", harga: "60000", asal: "Kanada"),
  ];

  // List<Map<String, dynamic>> dataProduk = [
  //   {"nama": "Apel", "harga": 25000, "asal": "Jepang"},
  //   {"nama": "Pisang", "harga": 15000, "asal": "Indonesia"},
  //   {"nama": "Jeruk", "harga": 20000, "asal": "Spanyol"},
  //   {"nama": "Mangga", "harga": 30000, "asal": "India"},
  //   {"nama": "Anggur", "harga": 40000, "asal": "Italia"},
  //   {"nama": "Semangka", "harga": 18000, "asal": "Brazil"},
  //   {"nama": "Melon", "harga": 22000, "asal": "Australia"},
  //   {"nama": "Kiwi", "harga": 50000, "asal": "Selandia Baru"},
  //   {"nama": "Nanas", "harga": 12000, "asal": "Filipina"},
  //   {"nama": "Stroberi", "harga": 45000, "asal": "Amerika Serikat"},
  //   {"nama": "Durian", "harga": 60000, "asal": "Thailand"},
  //   {"nama": "Rambutan", "harga": 25000, "asal": "Malaysia"},
  //   {"nama": "Pepaya", "harga": 10000, "asal": "Meksiko"},
  //   {"nama": "Jambu", "harga": 15000, "asal": "Vietnam"},
  //   {"nama": "Leci", "harga": 35000, "asal": "Cina"},
  //   {"nama": "Delima", "harga": 30000, "asal": "Iran"},
  //   {"nama": "Sirsak", "harga": 20000, "asal": "Karibia"},
  //   {"nama": "Ceri", "harga": 55000, "asal": "Turki"},
  //   {"nama": "Alpukat", "harga": 40000, "asal": "Meksiko"},
  //   {"nama": "Blueberry", "harga": 60000, "asal": "Kanada"},
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: index % 2 == 0 ? Colors.red[200] : Colors.grey[200],
            title: Text(dataProduk[index].nama),
            subtitle: Text(dataProduk[index].asal),
            trailing: Text(dataProduk[index].harga.toString()),
          );
        },
      ),
    );
  }
}
