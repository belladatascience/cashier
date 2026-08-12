import 'package:flutter/material.dart';

class InputWidgetDay13 extends StatefulWidget {
  const InputWidgetDay13({super.key});

  @override
  State<InputWidgetDay13> createState() => _InputWidgetDay13State();
}

class _InputWidgetDay13State extends State<InputWidgetDay13> {
  bool _isCheck = false;
  bool _isOn = false;
  String? _selected;
  DateTime? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _isOn ? Colors.white : Colors.black,
      child: Column(
        children: [
          //CheckBox
          CheckBoxWidget(),
          //Switc
          switchWidget(),
          //
          dropdownWidget(),
        ],
      ),
    );
  }

  Column dropdownWidget() {
    return Column(
      children: [
        DropdownButton(
          items: ["Merah", "Kuning", "Hijau"].map((String val) {
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
            fillColor: _selected == "Merah"
                ? Colors.red
                : _selected == "Kuning"
                ? Colors.yellow
                : _selected == "Hijau"
                ? Colors.green
                : Colors.white,
            filled: true,
          ),
          items: ["Merah", "Kuning", "Hijau"].map((String val) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selected = value;
            });
          },
        ),

        Text(_selected.toString()),

        Container(
          height: 50,
          width: 50,
          color: _selected == "Merah"
              ? Colors.red
              : _selected == "Kuning"
              ? Colors.yellow
              : Colors.green,
        ),
      ],
    );
  }

  Column switchWidget() {
    return Column(
      children: [
        Switch(
          activeThumbColor: Colors.amber,
          inactiveThumbColor: Colors.black,
          value: _isOn,
          onChanged: (value) {
            _isOn = value ?? false;
            setState(() {});
          },
        ),
        Text(_isOn ? "Matiin" : "Hidupin"),
      ],
    );
  }

  Column CheckBoxWidget() {
    return Column(
      children: [
        Column(
          children: [
            Checkbox(
              value: _isCheck,
              onChanged: (value) {
                _isCheck = value ?? false;
                setState(() {});
              },
            ),
            Text(_isCheck ? "Sudah di ceklist" : "Belum di ceklist"),
          ],
        ),
      ],
    );
  }
}
