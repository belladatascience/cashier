import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Showdatepickertugas7 extends StatefulWidget {
  const Showdatepickertugas7({super.key});

  @override
  State<Showdatepickertugas7> createState() => _Showdatepickertugas7State();
}

class _Showdatepickertugas7State extends State<Showdatepickertugas7> {
  DateTime? _selectedTime;
  TimeOfDay? _selectedTimeOfDay;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          //  datePickerWidget(BuildContext context) {
          //     return Column(
          //       children: [
          ElevatedButton(
            onPressed: () async {
              // Memunculkan dialog Date Picker bawaan Flutter.
              final DateTime? picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2021),
                lastDate: DateTime.now(),
                initialDate: DateTime.now(),
              );

              // Jika user memilih tanggal, simpan nilainya ke state dan rebuild UI.
              if (picked != null) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },

            child: Text("Pilih Tanggal"),
          ),
          // Menampilkan tanggal mentah (toString).
          Text(
            _selectedTime == null
                ? "Anda belum pilih tanggal"
                : _selectedTime.toString(),
          ),
          // Menampilkan tahun saja (yyyy).
          Text(
            _selectedTime == null
                ? "Anda belum pilih tanggal"
                : DateFormat('yyyy').format(_selectedTime ?? DateTime.now()),
          ),
          // Menampilkan format lengkap Indonesia: Hari, Tanggal Bulan Tahun (misal: Senin, 03 Agustus 2026).
          Text(
            _selectedTime == null
                ? "Anda belum pilih tanggal"
                : DateFormat(
                    'EEEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(_selectedTime ?? DateTime.now()),
          ),
          // Menampilkan format hari singkat: Sen, 03 Agustus 2026.
          Text(
            _selectedTime == null
                ? "Anda belum pilih tanggal"
                : DateFormat(
                    'EEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(_selectedTime ?? DateTime.now()),
          ),
          // Menampilkan format hari singkat dan bulan singkat: Sen, 03/Ags/2026.
          Text(
            _selectedTime == null
                ? "Anda belum pilih tanggal"
                : DateFormat(
                    'EEE, dd/MMM/yyyy',
                    'id_ID',
                  ).format(_selectedTime ?? DateTime.now()),
          ),
        ],
      ),
    );
  }
}
