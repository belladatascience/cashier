import 'package:flutter/material.dart';

class Listviewbuildertugas9A extends StatelessWidget {
  Listviewbuildertugas9A({super.key});

  List<Map<String, dynamic>> dataProduk = [
    {"nama": "Buku", "harga": 25000, "asal": "Jepang"},
    {"nama": "Pulpen", "harga": 15000, "asal": "Indonesia"},
    {"nama": "Pensil", "harga": 20000, "asal": "Spanyol"},
    {"nama": "Penggaris", "harga": 30000, "asal": "India"},
    {"nama": "Penghapus", "harga": 40000, "asal": "Italia"},
    {"nama": "Meja", "harga": 18000, "asal": "Brazil"},
    {"nama": "Kursi", "harga": 22000, "asal": "Australia"},
    {"nama": "Amplop", "harga": 50000, "asal": "Selandia Baru"},
    {"nama": "Papan Tulis", "harga": 12000, "asal": "Filipina"},
    {"nama": "Rautan", "harga": 45000, "asal": "Amerika Serikat"},
    {"nama": "Baterai", "harga": 60000, "asal": "Thailand"},
    {"nama": "Gunting", "harga": 25000, "asal": "Malaysia"},
    {"nama": "Mouse", "harga": 10000, "asal": "Meksiko"},
    {"nama": "Tas", "harga": 15000, "asal": "Vietnam"},
    {"nama": "Binder", "harga": 35000, "asal": "Cina"},
    {"nama": "Name Tag", "harga": 30000, "asal": "Iran"},
    {"nama": "Kalkulator", "harga": 20000, "asal": "Karibia"},
    {"nama": "Clips", "harga": 55000, "asal": "Turki"},
    {"nama": "Stapler", "harga": 40000, "asal": "Meksiko"},
    {"nama": "Stabilo", "harga": 60000, "asal": "Kanada"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: index % 2 == 0 ? Colors.red[200] : Colors.grey[200],
            title: Text(dataProduk[index]["nama"]),
            subtitle: Text(dataProduk[index]["asal"]),
            trailing: Text(dataProduk[index]["harga"].toString()),
          );
        },
      ),
    );
  }
}
