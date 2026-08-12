import 'package:flutter/material.dart';

class tugas1 extends StatelessWidget {
  const tugas1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 180, 89, 56),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bella Gita Asmara',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 15, 216, 156),
                  size: 20,
                ),
                Text('Jakarta Selatan', style: TextStyle(fontSize: 16)),
              ],
            ),

            const Text(
              'Seorang peserta pelatihan yang sedang mendalami Flutter di PPKD Jakarta Pusat.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
