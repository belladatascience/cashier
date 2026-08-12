import 'package:cashier/8SQFLITE_CRUD/Tugas12.dart/database/databasehelper.dart';
import 'package:cashier/8SQFLITE_CRUD/Tugas12.dart/models/user_logintugas12.dart';
import 'package:flutter/material.dart';

class DataUsertugas12 extends StatefulWidget {
  const DataUsertugas12({super.key});

  @override
  State<DataUsertugas12> createState() => _DataUsertugas12State();
}

class _DataUsertugas12State extends State<DataUsertugas12> {
  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showBottomSheet(context, UserModelSQL(email: "", password: ""));
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<UserModelSQL>>(
              future: DBHelper().getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data pengguna.'));
                }

                final daftarPengguna = snapshot.data!;

                return ListView.builder(
                  itemCount: daftarPengguna.length,
                  itemBuilder: (context, index) {
                    final user = daftarPengguna[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.nama ?? user.email),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Email: ${user.email}'),
                            Text('Password: ${user.password}'),
                            Text('Nomor HP: ${user.nomor_hp ?? "-"}'),
                            // MENAMPILKAN ASAL KOTA
                            Text('Asal Kota: ${user.asalKota ?? "-"}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                _showBottomSheet(context, user);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (user.id != null) {
                                  await DBHelper().deleteUser(user.id!);
                                  _refreshList();
                                }
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

  void _showBottomSheet(BuildContext context, UserModelSQL? user) {
    final emailController = TextEditingController(text: user?.email ?? "");
    final passwordController = TextEditingController(
      text: user?.password ?? "",
    );
    final namaController = TextEditingController(text: user?.nama ?? "");
    final noHpController = TextEditingController(text: user?.nomor_hp ?? "");
    final asalKotaController = TextEditingController(
      text: user?.asalKota ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: asalKotaController,
                decoration: const InputDecoration(
                  labelText: 'Asal Kota',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final newUser = UserModelSQL(
                    nama: namaController.text,
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    nomor_hp: noHpController.text,
                    asalKota: asalKotaController.text,
                  );

                  bool success = await DBHelper().registerUser(newUser);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _refreshList();
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                          nama: namaController.text,
                          email: emailController.text.trim(),
                          password: passwordController.text,
                          nomor_hp: noHpController.text,
                          asalKota: asalKotaController.text,
                        );

                        bool success = await DBHelper().updateUser(updatedUser);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                        }
                      }
                    },
                  ),
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
