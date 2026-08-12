import 'package:flutter/material.dart';

class Switchtugas7 extends StatefulWidget {
  const Switchtugas7({super.key});

  @override
  State<Switchtugas7> createState() => _Switchtugas7State();
}

class _Switchtugas7State extends State<Switchtugas7> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _isOn ? Colors.white : Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Aktifkan mode gelap",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Switch(
            activeThumbColor: Colors.amber,
            inactiveThumbColor: Colors.black,
            value: _isOn,
            onChanged: (value) {
              setState(() {
                _isOn = value;
              });
            },
          ),
          Text(
            _isOn ? "Off" : "On",
            style: TextStyle(
              color: _isOn ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
