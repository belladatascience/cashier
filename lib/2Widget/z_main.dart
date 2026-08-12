import 'package:flutter/material.dart';

class _ContohLatihanDay9State extends StatefulWidget {
  const _ContohLatihanDay9State({super.key});

  @override
  State<_ContohLatihanDay9State> createState() =>
      __ContohLatihanDay9StateState();
}

class __ContohLatihanDay9StateState extends State<_ContohLatihanDay9State> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),

          ElevatedButton(
            onPressed: () {
              debugPrint('Notifikasi Debug Console');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Kontak disentuh')));
            },
            child: const Text('Klik Saya'),
          ),

          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              setState(() {});
              debugPrint("ikon diklik");
            },
          ),

          TextButton(
            onPressed: () {
              debugPrint("Text Button");
            },
            child: Text("Baca Selengkapnya"),
          ),

          GestureDetector(
            onTap: () {
              debugPrint("Disentuh sekali");
            },
          ),

          InkWell(
            onTap: () {
              debugPrint("Gambar diklik");
            },
            child: Text("CONTOH"),
          ),
          SizedBox(height: 50),

          GestureDetector(
            onTap: () {
              debugPrint("Disentuh Sekali");
            },
            onDoubleTap: () {
              debugPrint("Tahan Lama");
            },
            child: Container(
              color: Colors.blue,
              padding: EdgeInsets.all(8),
              child: Text("Text Saya"),
            ),
          ),

          FloatingActionButton(
            onPressed: () {
              debugPrint("FAB ditekan");
            },

            tooltip: "Tambah Data",
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
