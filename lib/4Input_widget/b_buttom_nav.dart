import 'package:cashier/7Shared_preference/service/preference_handler.dart';
import 'package:cashier/7Shared_preference/views/login.dart';
import 'package:cashier/8SQFLITE_CRUD/tugas12.dart/views/data_usertugas12.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';

class BottomNavDay13 extends StatefulWidget {
  const BottomNavDay13({super.key});

  @override
  State<BottomNavDay13> createState() => _BottomNavDay13State();
}

class _BottomNavDay13State extends State<BottomNavDay13> {
  int _selectedBottom = 0;

  void changeBottom(int index) {
    _selectedBottom = index;
    print("ini adalah value dari $_selectedBottom");
    setState(() {});
  }

  final List<Widget> _widgetOptions = [
    DataUsertugas12(),
    Center(child: Text("School")),
    Center(child: Text("Business")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          changeBottom(value);
        },
        currentIndex: _selectedBottom,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "school"),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "business",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
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
