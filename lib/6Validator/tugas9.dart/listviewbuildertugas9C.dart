import 'package:flutter/material.dart';

class Listviewbuildertugas9c extends StatelessWidget {
  Listviewbuildertugas9c({super.key});

  List<Map<String, dynamic>> alatTuliskantor = [
    {"nama": "Buku", "harga": 25000, "image": "assets/images/books.png"},
    {"nama": "Pulpen", "harga": 15000, "image": "assets/images/pen.png"},
    {"nama": "Pensil", "harga": 20000, "image": "assets/images/pencil.png"},
    {"nama": "Penggaris", "harga": 30000, "image": "assets/images/ruler.png"},
    {"nama": "Penghapus", "harga": 40000, "image": "assets/images/eraser.png"},
    {"nama": "Meja", "harga": 18000, "image": "assets/images/table.png"},
    {"nama": "Kursi", "harga": 22000, "image": "assets/images/kursi.png"},
    {"nama": "Amplop", "harga": 50000, "image": "assets/images/amplop.png"},
    {
      "nama": "Papan Tulis",
      "harga": 12000,
      "image": "assets/images/papan tulis.png",
    },
    {"nama": "Rautan", "harga": 45000, "image": "assets/images/rautan.png"},
    {"nama": "Baterai", "harga": 60000, "image": "assets/images/baterai.png"},
    {"nama": "Gunting", "harga": 25000, "image": "assets/images/gunting.png"},
    {"nama": "Mouse", "harga": 10000, "image": "assets/images/mouse.png"},
    {"nama": "Tas", "harga": 15000, "image": "assets/images/tas.png"},
    {"nama": "Binder", "harga": 35000, "image": "assets/images/binder.png"},
    {"nama": "Name Tag", "harga": 30000, "image": "assets/images/nametag.png"},
    {
      "nama": "Kalkulator",
      "harga": 20000,
      "image": "assets/images/kalkulator.png",
    },
    {"nama": "Clips", "harga": 55000, "image": "assets/images/clips.png"},
    {"nama": "Stapler", "harga": 40000, "image": "assets/images/stapler.png"},
    {"nama": "Stabilo", "harga": 60000, "image": "assets/images/stabilo.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Alat Tulis")),
      body: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: alatTuliskantor.length,
        itemBuilder: (BuildContext context, int index) {
          final item = alatTuliskantor[index];

          return ListTile(
            tileColor: index % 2 == 0 ? Colors.red[100] : Colors.grey[200],
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item["image"],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(item["nama"]),
            subtitle: Text("Rp ${item["harga"]}"),
          );
        },
      ),
    );
  }
}
