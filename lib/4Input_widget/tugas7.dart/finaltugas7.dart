import 'package:cashier/4Input_widget/tugas7.dart/a_checkboxtugas7.dart';
import 'package:cashier/4Input_widget/tugas7.dart/b_switchtugas7.dart';
import 'package:cashier/4Input_widget/tugas7.dart/c_dropdownButtontugas7.dart';
import 'package:cashier/4Input_widget/tugas7.dart/d_showdatepickertugas7.dart';
import 'package:cashier/4Input_widget/tugas7.dart/e_showtimepickertugas7.dart';
import 'package:cashier/5ListOfMap/tugas8.dart/b_list.dart';
import 'package:cashier/5ListOfMap/tugas8.dart/d_listofmap.dart';
import 'package:cashier/5ListOfMap/tugas8.dart/e_listofmodel.dart';
import 'package:cashier/6Validator/tugas10.dart/textFormfield.dart';
import 'package:cashier/6Validator/tugas9.dart/listviewbuildertugas9A.dart';
import 'package:cashier/6Validator/tugas9.dart/listviewbuildertugas9B.dart';
import 'package:cashier/6Validator/tugas9.dart/listviewbuildertugas9C.dart';
import 'package:cashier/7Shared_preference/service/preference_handler.dart';
import 'package:cashier/7Shared_preference/views/login.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';

class Tugas7flutter extends StatefulWidget {
  const Tugas7flutter({super.key});

  @override
  State<Tugas7flutter> createState() => _Tugas7flutterState();
}

class _Tugas7flutterState extends State<Tugas7flutter> {
  int _selectedBottom = 0;
  final bool _isCheck = false;
  final bool _isOn = false;
  String? _selected;
  DateTime? _selectedTime;
  TimeOfDay? _selectedTimeOfDay;

  void changeBottom(int index) {
    _selectedBottom = index;
    print("Ini adalah value dari $_selectedBottom");
    setState(() {});
    context.pop();
  }

  final List<Widget> _widgetOptions = [
    Checkboxtugas7(),
    Switchtugas7(),
    Dropdownbuttontugas7(),
    Showdatepickertugas7(),
    Showtimepickertugas7(),
    ListDataDay15(),
    ListOfMapDay15(),
    ListOfModelDay15(),
    Listviewbuildertugas9A(),
    listViewbuildertugas9B(),
    Listviewbuildertugas9c(),
    TextFormFieldtugas10(),
    LoginDay17(),
    LogoutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drawer")),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Center(child: Text("Tugas7Flutter- Menu Input")),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text("Syarat & Ketentuan"),
              onTap: () {
                changeBottom(0);

                // ElevatedButton(
                //   onPressed: () async {
                //     final DateTime? picked = await showDatePicker(
                //       context: context,
                //       firstDate: DateTime(2021),
                //       lastDate: DateTime.now(),
                //       initialDate: DateTime.now(),
                //     );
                //     if (picked != null) {
                //       setState(() {
                //         _selectedTime = picked;
                //       });
                //     }
                //   },
                // );
              },
            ),

            // ListTile(
            //   leading: Icon(Icons.architecture),
            //   title: Text("Mode Tampilan"),
            //   onTap: () {
            //     changeBottom(1);
            //   },
            // ),

            // ListTile(
            //   leading: Icon(Icons.shopping_bag),
            //   title: Text("Kategori Produk"),
            //   onTap: () {
            //     changeBottom(2);
            //   },
            // ),

            // ListTile(
            //   leading: Icon(Icons.calendar_month),
            //   title: Text("Pilih Tanggal"),
            //   onTap: () {
            //     changeBottom(3);
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text("Atur Pengingat"),
              onTap: () {
                changeBottom(4);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("List Data"),
              onTap: () {
                changeBottom(5);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("List Of MAP Day 15"),
              onTap: () {
                changeBottom(6);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("List Of Model Day 15"),
              onTap: () {
                changeBottom(7);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("List View Builder A"),
              onTap: () {
                changeBottom(8);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("List View Builder B"),
              onTap: () {
                changeBottom(9);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("List View Builder C"),
              onTap: () {
                changeBottom(10);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("Text Form Field 10"),
              onTap: () {
                changeBottom(11);
              },
            ),

            ListTile(
              leading: Icon(Icons.list),
              title: Text("LoginDay17"),
              onTap: () {
                changeBottom(12);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("logout"),
              onTap: () {
                changeBottom(13);
              },
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAtOrNull(_selectedBottom),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 1. Menghapus session status login di SharedPreferences lokal.
        PreferenceHandler.logOut();

        // 2. Mengarahkan pengguna kembali ke halaman LoginDay17 serta menghapus seluruh tumpukan navigasi sebelumnya (pushAndRemoveAll).
        context.pushAndRemoveAll(const LoginDay17());
      },
      child: const Center(child: Icon(Icons.logout, size: 48)),
    );
  }
}
