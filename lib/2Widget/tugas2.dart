import 'package:flutter/material.dart';

class tugas2flutter extends StatelessWidget {
  const tugas2flutter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 184, 120, 24),
        centerTitle: true,
        title: Text("Detail Toko"),
        foregroundColor: Colors.white,
      ),
      body: Align(
        child: Column(
          children: [
            // Identitas Utama
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Bee Business Consultant",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 143, 112, 22),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detail Kontak
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.email, color: Color.fromARGB(255, 189, 155, 6)),
                    SizedBox(width: 10),
                    Text("bellagita.asmara"),
                  ],
                ),
              ),
            ),

            // Informasi Pendukung
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: const [
                  Icon(Icons.phone, color: Color.fromARGB(255, 173, 10, 132)),
                  SizedBox(width: 10),
                  Text("+6287888848000"),
                  Spacer(),
                  Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 186, 10, 202),
                  ),
                  SizedBox(width: 5),
                  Text("Jakarta, Indonesia"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistik Horizontal
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Column(
                      children: const [
                        Text(
                          "800+",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Stok Sold / Month"),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          "4.8 / 5 ⭐",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("User Rating"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Deskripsi Naratif
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Bee Business Consultant adalah penyedia jasa konsultan untuk perusahaan",
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Visual Branding
            Container(
              height: 300,
              width: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bisnis bella foto.jpg"),
                ),
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
