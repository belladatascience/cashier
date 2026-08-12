import 'package:flutter/material.dart';

class Tugas4Flutterr extends StatelessWidget {
  const Tugas4Flutterr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cashier Latte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      // WAJIB: ListView sebagai root di body
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- BAGIAN FORM ---
          const Text(
            'Customers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 4 TextField disesuaikan
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nama Pelanggan',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Lokasi Pembelian',
              hintText: 'Contoh: Order Makanan & Minuman',
              prefixIcon: Icon(Icons.map),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Orderan',
              prefixIcon: Icon(Icons.calculate),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          const TextField(
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Pesanan',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 12),

          // --- BAGIAN DAFTAR / RIWAYAT ---
          const Text(
            'Riwayat Penjualan Terakhir',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Minimal 5 ListTile ditulis manual
          _buildListTile(
            icon: Icons.coffee,
            iconColor: Colors.brown,
            title: 'Alex',
            subtitle:
                'Cafe Bee. 2 Items. 1 Latte, 1 Bread Butter. Dibayar 1 hari lalu.',
          ),
          _buildListTile(
            icon: Icons.coffee,
            iconColor: Colors.yellow,
            title: 'Handky',
            subtitle:
                'Cafe Bee. 5 Items. 3 Latte, 2 Croissant. Dibayar 1 hari lalu.',
          ),
          _buildListTile(
            icon: Icons.coffee,
            iconColor: Colors.blue,
            title: 'Baby',
            subtitle: 'Cafe Bee. 1 Item. 1 Americano. Dibayar 1 hari lalu .',
          ),
          _buildListTile(
            icon: Icons.coffee,
            iconColor: Colors.pink,
            title: 'Cherly',
            subtitle:
                'Cafe Bee. 4 Items. 2 Latte, 2 Signature Chocolate. Dibayar 1 hari lalu .',
          ),
          _buildListTile(
            icon: Icons.coffee,
            iconColor: Colors.purple,
            title: 'Bens',
            subtitle: 'Cafe Bee. 10 Items. 10 Latte. Dibayar 1 hari lalu.',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget helper biar ga ngulang kode ListTile
  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey[100],
      ),
    );
  }
}
