import 'package:cashier/halaman1/models/user_login.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = DataBaseHelper._internal();
  factory DataBaseHelper() => _instance;
  DataBaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ppkd.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            nomor_hp TEXT,
            nama TEXT,
            asalKota TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE siswa(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            kelas TEXT
          )
        ''');

        // Otomatis buatkan akun kasir bawaan/default jika pertama kali di-install
        await db.insert('users', {
          'email': 'KASIR01',
          'password': '123',
          'nama': 'Kasir Utama BGA',
          'nomor_hp': '08123456789',
          'asalKota': 'Jakarta',
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE users ADD COLUMN nomor_hp TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE users ADD COLUMN nama TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE users ADD COLUMN asalKota TEXT');
          } catch (_) {}
        }
      },
    );
  }

  Future<bool> registerUser(UserModelSQL pengguna) async {
    final db = await database;
    try {
      await db.insert('users', pengguna.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Login menggunakan Email atau ID Kasir
  Future<UserModelSQL?> loginUser(String emailOrId, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: '(email = ? OR nomor_hp = ?) AND password = ?',
      whereArgs: [emailOrId, emailOrId, password],
    );

    if (results.isNotEmpty) {
      return UserModelSQL.fromMap(results.first);
    }
    return null;
  }

  Future<List<UserModelSQL>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('users');
    return results.map((map) => UserModelSQL.fromMap(map)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> updateUser(UserModelSQL pengguna) async {
    final db = await database;
    try {
      int count = await db.update(
        'users',
        pengguna.toMap(),
        where: 'id = ?',
        whereArgs: [pengguna.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
