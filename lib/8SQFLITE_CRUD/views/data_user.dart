import 'package:cashier/8SQFLITE_CRUD/database/db_helper.dart';
import 'package:cashier/8SQFLITE_CRUD/models/user_login.dart';
import 'package:flutter/material.dart';
// import 'package:ppkd_b7/day_18/database/db_helper.dart';
// import 'package:ppkd_b7/day_18/models/user_login_model.dart';

class DataUserDay18 extends StatefulWidget {
  const DataUserDay18({super.key});

  @override
  State<DataUserDay18> createState() => _DataUserDay18State();
}

class _DataUserDay18State extends State<DataUserDay18> {
  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // Tombol Tambah Pengguna Baru
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Membuka modal bottom sheet dengan objek pengguna kosong untuk pendaftaran baru.
          _showBottomSheet(context, UserModelSQL(email: "", password: ""));
        },
      ),
      body: Column(
        children: [
          Expanded(
            // FutureBuilder digunakan untuk mengambil data secara asynchronous dari fungsi DBHelper().getAllUsers()
            child: FutureBuilder<List<UserModelSQL>>(
              future: DBHelper().getAllUsers(),
              builder: (context, snapshot) {
                // Status 1: Sedang memuat data dari database
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Status 2: Terjadi error saat membaca data
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                // Status 3: Data kosong / belum ada pengguna di database
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data pengguna.'));
                }

                // Status 4: Data berhasil diambil
                final daftarPengguna = snapshot.data!;

                return ListView.builder(
                  itemCount: daftarPengguna.length,
                  itemBuilder: (context, index) {
                    final user = daftarPengguna[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.email),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Password: ${user.password}'),
                            Text('Nomor HP: ${user.nomorHp ?? "-"}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Edit Data Pengguna
                            IconButton(
                              onPressed: () {
                                _showBottomSheet(context, user);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            // Tombol Hapus Data Pengguna
                            IconButton(
                              onPressed: () {
                                _showBottomSheet(context, user);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper Modal Bottom Sheet untuk menginputkan data Tambah, Edit, atau Hapus pengguna.
  void _showBottomSheet(BuildContext context, UserModelSQL? user) {
    // Inisialisasi controller teks dari data pengguna yang dipilih (jika ada).
    final emailController = TextEditingController(text: user?.email ?? "");
    final passwordController = TextEditingController(
      text: user?.password ?? "",
    );
    final noHpController = TextEditingController(text: user?.nomorHp ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Supaya bottom sheet menyesuaikan tinggi keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kelola Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Input Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Input Password
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Input Nomor HP
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Aksi 1: Tambah Pengguna Baru
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final newUser = UserModelSQL(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    nomorHp: noHpController.text,
                  );

                  bool success = await DBHelper().registerUser(newUser);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _refreshList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data berhasil ditambahkan'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              // Baris Aksi 2 & 3: Update dan Delete Data Pengguna
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Aksi 2: Update Pengguna
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (user?.id != null) {
                        final updatedUser = UserModelSQL(
                          id: user?.id,
                          email: emailController.text.trim(),
                          password: passwordController.text,
                          nomorHp: noHpController.text,
                        );

                        bool success = await DBHelper().updateUser(updatedUser);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil diperbarui'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  // Aksi 3: Delete Pengguna
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (user?.id != null) {
                        await DBHelper().deleteUser(user!.id!);
                        if (context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil dihapus'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
