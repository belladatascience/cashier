import 'package:flutter/material.dart';

class ListDataDay15 extends StatelessWidget {
  ListDataDay15({super.key});

  List<String> namaBuah = [
    "Apel",
    "Mangga",
    "Pisang",
    "Jeruk",
    "Anggur",
    "Semangka",
    "Melon",
    "Stroberi",
    "Nanas",
    "Pepaya",
    "Durian",
    "Rambutan",
    "Nangka",
    "Salak",
    "Alpukat",
    "Ceri",
    "Kelapa",
    "Manggis",
    "Jambu",
    "Kiwi",
    "Markisa",
    "Lemon",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: namaBuah.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(namaBuah[index]);
        },
      ),
    );
  }
}
