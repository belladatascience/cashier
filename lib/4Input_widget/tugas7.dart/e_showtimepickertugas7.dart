import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Showtimepickertugas7 extends StatefulWidget {
  const Showtimepickertugas7({super.key});

  @override
  State<Showtimepickertugas7> createState() => _Showtimepickertugas7State();
}

class _Showtimepickertugas7State extends State<Showtimepickertugas7> {
  TimeOfDay? _selectedTimeOfDay;
  TimeOfDayFormat? _timeOfDayFormat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // Mengatur warna latar belakang secara dinamis berdasarkan state _isOn (Switch).
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              // Memunculkan dialog Time Picker bawaan Flutter.
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              // Jika user memilih waktu (tidak batal), simpan nilainya ke state dan rebuild UI.
              if (picked != null) {
                setState(() {
                  _selectedTimeOfDay = picked;
                });
              }
            },
            child: Text("Pilih Jam"),
          ),
          // Menampilkan representasi String mentah dari TimeOfDay yang dipilih.
          Text(
            _selectedTimeOfDay == null
                ? "Anda belum pilih jam"
                : _selectedTimeOfDay.toString(),
          ),
          // Menampilkan waktu terpilih dengan format 24 Jam (HH:mm) menggunakan DateFormat.
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
}
