import 'package:flutter/material.dart';

class Dropdownbuttontugas7 extends StatefulWidget {
  const Dropdownbuttontugas7({super.key});

  @override
  State<Dropdownbuttontugas7> createState() => _Dropdownbuttontugas7State();
}

class _Dropdownbuttontugas7State extends State<Dropdownbuttontugas7> {
  String? _selected;
  IconData _getCategoryIcon() {
    switch (_selected) {
      case "Elektronik":
        return Icons.devices;
      case "Pakaian":
        return Icons.checkroom;
      case "Makanan":
        return Icons.restaurant;
      case "Lainnya":
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return dropdownWidget();
  }

  Column dropdownWidget() {
    return Column(
      children: [
        DropdownButton(
          items: ["Elektronik", "Pakaian", "Makanan", "Lainnya"].map((
            String val,
          ) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selected = value;
            });
          },
        ),

        DropdownButtonFormField(
          decoration: InputDecoration(
            fillColor: _selected == "Elektronik"
                ? Colors.blue
                : _selected == "Pakaian"
                ? Colors.yellow
                : _selected == "Makanan"
                ? Colors.pink
                : _selected == "Lainnya"
                ? Colors.green
                : Colors.white,
            filled: true,
          ),
          items: ["Elektronik", "Pakaian", "Makanan", "Lainnya"].map((
            String val,
          ) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selected = value;
            });
          },
        ),

        Text(_selected.toString()),

        Text(
          "Anda memilih kategori: ${_selected ?? '-'}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Icon(_getCategoryIcon(), size: 60, color: Colors.amber),

        // Container(
        //   height: 50,
        //   width: 50,
        //   color: _selected == "Elektronik"
        //       ? Colors.blue
        //       : _selected == "Pakaian"
        //       ? Colors.yellow
        //       : _selected == "Makanan"
        //       ? Colors.green
        //       : _selected == "Lainnya"
        //       ? Colors.pink
        //       : Colors.blue,
        // ),
      ],
    );
  }
}
