import 'package:flutter/material.dart';

class Checkboxtugas7 extends StatefulWidget {
  const Checkboxtugas7({super.key});

  @override
  State<Checkboxtugas7> createState() => _Checkboxtugas7State();
}

class _Checkboxtugas7State extends State<Checkboxtugas7> {
  bool _isCheck = false;

  //
  @override
  Widget build(BuildContext context) {
    return CheckBoxWidget();
  }

  Column CheckBoxWidget() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isCheck,
                  onChanged: (value) {
                    _isCheck = value ?? false;
                    setState(() {});
                  },
                ),
              ],
            ),

            Text(
              _isCheck
                  ? "Pendaftaran diperbolehkan"
                  : "Pendaftaran belum tersedia",
            ),
          ],
        ),
      ],
    );
  }
}
