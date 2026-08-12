import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputWidgetDay133 extends StatefulWidget {
  const InputWidgetDay133({super.key});

  @override
  State<InputWidgetDay133> createState() => _InputWidgetDay133State();
}

class _InputWidgetDay133State extends State<InputWidgetDay133> {
  bool _isCheck = false;
  bool _isOn = false;
  String? _selected;
  DateTime? _selectedTime;
  TimeOfDay? _selectedTimeOfDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _isOn ? Colors.white : Colors.black,
      child: Column(
        children: [
          //CheckBox
          CheckBoxWidget(),
          //Switch
          switchWidget(),
          //DropDownButton
          dropdownWidget(),
          //Date Picker
          datePickerWidget(context),

          //Time Picker
          ElevatedButton(
            onPressed: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                // firstDate: DateTime(2021),
                // lastDate: DateTime.now(),
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedTimeOfDay = picked;
                });
              }
            },
            child: Text("Pilih Jam"),
          ),

          Text(
            _selectedTimeOfDay == null
                ? "Anda belum pilih jam"
                : DateFormat('HH:mm').format(
                    DateTime(
                      0,
                      0,
                      0,
                      _selectedTimeOfDay!.hour,
                      _selectedTimeOfDay!.minute,
                    ),
                  ),
          ),

          Text(
            _selectedTimeOfDay == null
                ? "Anda belum pilih jam"
                : DateFormat("HH:mm").format(
                    DateTime(
                      0,
                      0,
                      0,
                      _selectedTimeOfDay!.hour,
                      _selectedTimeOfDay!.minute,
                    ),
                  ),
          ),

          Text(
            _selectedTimeOfDay == null
                ? "Anda belum pilih jam"
                : DateFormat('HH:mm').format(
                    DateTime(
                      0,
                      0,
                      0,
                      _selectedTimeOfDay!.hour,
                      _selectedTimeOfDay!.minute,
                    ),
                  ),
          ),

          ElevatedButton(onPressed: () {}, child: Text("Pilih Tanggal")),
          Text(
            _selectedTimeOfDay == null
                ? "Anda belum pilih jam"
                : DateFormat('HH:mm').format(
                    DateTime(
                      0,
                      0,
                      0,
                      _selectedTimeOfDay!.hour,
                      _selectedTimeOfDay!.minute,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Column datePickerWidget(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2021),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedTime = picked;
              });
            }
          },
          child: Text("Pilih Tanggal"),
        ),

        Text(
          _selectedTime == null
              ? "Anda belum pilih tanggal"
              : DateFormat(
                  'EEE, dd MMM yyyy',
                ).format(_selectedTime ?? DateTime.now()),
        ),

        Text(
          _selectedTime == null
              ? "Anda belum pilih tanggal"
              : DateFormat(
                  'EEE, dd MMM yyyy',
                ).format(_selectedTime ?? DateTime.now()),
        ),

        Text(
          _selectedTime == null
              ? "Anda belum pilih tanggal"
              : DateFormat(
                  'EEE, dd MMM yyyy',
                ).format(_selectedTime ?? DateTime.now()),
        ),

        Text(
          _selectedTime == null
              ? "Anda belum pilih tanggal"
              : DateFormat(
                  'EEE, dd MMM yyyy',
                ).format(_selectedTime ?? DateTime.now()),
        ),

        Text(
          _selectedTime == null
              ? "Anda belum pilih tanggal"
              : DateFormat(
                  'EEE, dd MMM yyyy',
                ).format(_selectedTime ?? DateTime.now()),
        ),

        ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2021),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedTime = picked;
              });
            }
          },
          child: Text("Pilih Tanggal"),
        ),

        ElevatedButton(onPressed: () {}, child: Text("Pilih Tanggal")),
        Text(
          _selectedTime == null
              ? "Anda belum pilih tanggal"
              : _selectedTime.toString(),
        ),
      ],
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
