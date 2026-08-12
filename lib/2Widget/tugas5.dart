import 'package:flutter/material.dart';

void main() {
  runApp(const InteraksiApp());
}

class InteraksiApp extends StatelessWidget {
  const InteraksiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas 5 Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const Tugas5Flutter(),
    );
  }
}

class Tugas5Flutter extends StatefulWidget {
  const Tugas5Flutter({super.key});

  @override
  State<Tugas5Flutter> createState() => _Tugas5FlutterState();
}

class _Tugas5FlutterState extends State<Tugas5Flutter> {
  bool showSecret = false;
  bool isFavorite = false;
  bool showDescription = false;
  String inkWellMessage = "";
  int counter = 10;

  void _kurangiCounter() {
    setState(() {
      if (counter > 0) counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Interaksi Flutter",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Ini tentang Elevated Button:"),
              SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showSecret = !showSecret;
                  });
                },
                child: const Text("Klik Saya!"),
              ),
              if (showSecret)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Halo, saya Developer!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Ini tentang IconButton"),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                  Text(
                    isFavorite ? "Tersimpan di Favorit" : "Belum Disukai",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text("Ini tentang TextButton:"),
              TextButton(
                onPressed: () {
                  setState(() {
                    showDescription = !showDescription;
                  });
                },
                child: const Text(
                  "Lihat Deskripsi!",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showDescription)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Ini adalah deskripsi tambahan yang muncul setelah tombol ditekan. "
                    "Tugas ini melatih kita membuat aplikasi yang responsif terhadap input pengguna.",
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              const Text("Ini tentang InkWell"),
              SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    inkWellMessage = "Sentuhan terdeteksi!";
                  });
                  print("Pesan rahasia: InkWell ditekan!");
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      "Sentuh Kotak Ini",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              if (inkWellMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    inkWellMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Column(
                children: [
                  const Text("Ini tentang GestureDetector:"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        counter += 1;
                      });
                      print("Ditekan sekali");
                    },
                    onDoubleTap: () {
                      setState(() {
                        counter += 2;
                      });
                      print("Ditekan dua kali");
                    },
                    onLongPress: () {
                      setState(() {
                        counter += 3;
                      });
                      print("Tahan lama");
                    },
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Center(
                        child: Text(
                          "Angka: $counter",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            textAlign: TextAlign.left,
                            "• Tap = +1\n• Double Tap = +2\n• Long Press = +3",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: FloatingActionButton(
                          onPressed: _kurangiCounter,
                          tooltip: 'Kurangi Counter',
                          child: const Icon(Icons.remove),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
