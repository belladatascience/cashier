import 'package:flutter/material.dart';

class listViewbuildertugas9B extends StatelessWidget {
  listViewbuildertugas9B({super.key});

  final List<Map<String, dynamic>> alatTuliskantor = [
    {"nama": "Buku", "harga": 25000, "icon": Icons.book},
    {"nama": "Pulpen", "harga": 15000, "icon": Icons.edit},
    {"nama": "Pensil", "harga": 20000, "icon": Icons.edit},
    {"nama": "Penggaris", "harga": 30000, "icon": Icons.rule},
    {"nama": "Penghapus", "harga": 40000, "icon": Icons.phonelink_erase},
    {"nama": "Meja", "harga": 18000, "icon": Icons.table_bar},
    {"nama": "Kursi", "harga": 22000, "icon": Icons.chair},
    {"nama": "Amplop", "harga": 50000, "icon": Icons.book},
    {"nama": "Papan Tulis", "harga": 12000, "icon": Icons.book},
    {"nama": "Rautan", "harga": 45000, "icon": Icons.edit},
    {"nama": "Baterai", "harga": 60000, "icon": Icons.battery_0_bar},
    {"nama": "Gunting", "harga": 25000, "icon": Icons.cut},
    {"nama": "Mouse", "harga": 10000, "icon": Icons.mouse},
    {"nama": "Tas", "harga": 15000, "icon": Icons.badge_rounded},
    {"nama": "Binder", "harga": 35000, "icon": Icons.book},
    {"nama": "Name Tag", "harga": 30000, "icon": Icons.tag},
    {"nama": "Kalkulator", "harga": 20000, "icon": Icons.calculate},
    {"nama": "Clips", "harga": 55000, "icon": Icons.label},
    {"nama": "Stapler", "harga": 40000, "icon": Icons.book},
    {"nama": "Stabilo", "harga": 60000, "icon": Icons.edit},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: 8);
        },
        itemCount: alatTuliskantor.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: index % 2 == 0 ? Colors.red[200] : Colors.grey[200],
            title: Text(alatTuliskantor[index]["nama"]),
            subtitle: Text(alatTuliskantor[index]["harga"].toString()),
            trailing: Icon(alatTuliskantor[index]["icon"]),
          );
        },
      ),
    );
  }
}
