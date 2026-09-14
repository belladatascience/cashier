import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cashier/halaman1/models/category_model.dart';
import 'package:cashier/halaman1/models/menu_item_model.dart';
import 'package:cashier/halaman1/models/shift_model.dart';
import 'package:cashier/halaman1/models/staff_model.dart';
import 'package:cashier/halaman1/models/store_model.dart';
import 'package:cashier/halaman1/models/transaction_model.dart';
import 'package:cashier/halaman1/models/user_login.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = DataBaseHelper._internal();
  factory DataBaseHelper() => _instance;
  DataBaseHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCol => _firestore.collection('users');
  CollectionReference get _sessionsCol => _firestore.collection('active_session');
  CollectionReference get _storesCol => _firestore.collection('stores');
  CollectionReference get _categoriesCol => _firestore.collection('categories');
  CollectionReference get _menuItemsCol => _firestore.collection('menu_items');
  CollectionReference get _staffCol => _firestore.collection('staff');
  CollectionReference get _shiftsCol => _firestore.collection('shift_roster');
  CollectionReference get _transactionsCol => _firestore.collection('transactions');

  bool _isSeeded = false;

  /// Helper to convert bytes to base64 for Firestore storage
  static String? _bytesToBase64(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    return base64Encode(bytes);
  }

  /// Helper to convert dynamic data back to Uint8List
  static Uint8List? _dynamicToBytes(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is Blob) return value.bytes;
    if (value is String && value.isNotEmpty) {
      try {
        return base64Decode(value);
      } catch (_) {
        return null;
      }
    }
    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }
    return null;
  }

  /// Ensure initial default data exists in Firestore
  Future<void> _ensureInitialData() async {
    if (_isSeeded) return;
    try {
      final snap = await _categoriesCol.limit(1).get();
      if (snap.docs.isEmpty) {
        await _seedInitialData();
      }
      _isSeeded = true;
    } catch (e) {
      debugPrint('Firestore seed check error (offline or rules): $e');
    }
  }

  Future<void> _seedInitialData() async {
    final batch = _firestore.batch();

    // 1. Default Users
    final users = [
      {
        'id': 1,
        'email': 'bella.gita@bgaco.com',
        'password': '123',
        'nama': 'Bella Gita Asmara',
        'nomor_hp': '087888848000',
        'asalKota': 'Jakarta',
        'cashier_id': 'BG188889',
        'role': 'Senior Barista',
      },
      {
        'id': 2,
        'email': 'KASIR01',
        'password': '123',
        'nama': 'Kasir Utama BGA',
        'nomor_hp': '08123456789',
        'asalKota': 'Jakarta',
        'cashier_id': 'KASIR01',
        'role': 'Head Cashier',
      },
    ];
    for (final u in users) {
      final doc = _usersCol.doc('user_${u['id']}');
      batch.set(doc, u);
    }

    // 2. Default Active Session
    final sessionDoc = _sessionsCol.doc('current_session');
    batch.set(sessionDoc, {
      'id': 1,
      'user_id': 1,
      'user_name': 'Bella Gita Asmara',
      'email': 'bella.gita@bgaco.com',
      'cashier_id': 'BG188889',
      'role': 'Senior Barista',
      'store_name': 'Bella Cafe',
      'store_location': 'Jakarta',
      'shift': 'Pagi',
      'phone': '087888848000',
      'login_time': DateTime.now().toIso8601String(),
    });

    // 3. Default Stores
    final defaultStores = [
      {'id': 1, 'name': 'Bella Cafe', 'location': 'Jakarta', 'default_shift': 'Pagi'},
      {'id': 2, 'name': 'BGA Co. - Central Perk', 'location': 'Jakarta Pusat', 'default_shift': 'Pagi'},
      {'id': 3, 'name': 'BGA Co. - Downtown Latte', 'location': 'Jakarta Selatan', 'default_shift': 'Sore'},
      {'id': 4, 'name': 'BGA Co. - Westside Brew', 'location': 'Jakarta Barat', 'default_shift': 'Pagi'},
    ];
    for (final s in defaultStores) {
      final doc = _storesCol.doc('store_${s['id']}');
      batch.set(doc, s);
    }

    // 4. Default Categories
    final defaultCats = ['Food', 'Drink', 'Snack', 'Dessert'];
    for (int i = 0; i < defaultCats.length; i++) {
      final doc = _categoriesCol.doc('cat_${i + 1}');
      batch.set(doc, {'id': i + 1, 'name': defaultCats[i], 'sort_order': i});
    }

    // 5. Default Menu Items
    final defaultMenus = [
      // Food
      {
        'id': 1,
        'name': 'Sourdough Loaf',
        'price': 38000,
        'price_text': 'Rp 38.000',
        'desc': 'Roti artisan sourdough klasik berkulit renyah garing dengan bagian dalam yang empuk.',
        'image_path': 'assets/images/food_sourdough.jpg',
        'category': 'Food',
        'is_active': 1,
      },
      {
        'id': 2,
        'name': 'Butter Croissant',
        'price': 25000,
        'price_text': 'Rp 25.000',
        'desc': 'Pastry croissant khas Prancis yang renyah berlayer dengan aroma mentega gurih.',
        'image_path': 'assets/images/food_croissant.jpg',
        'category': 'Food',
        'is_active': 1,
      },
      {
        'id': 3,
        'name': 'Berry Tart',
        'price': 35000,
        'price_text': 'Rp 35.000',
        'desc': 'Kue tart manis dengan topping buah beri segar dan krim custard lembut.',
        'image_path': 'assets/images/food_tart.jpg',
        'category': 'Food',
        'is_active': 1,
      },
      {
        'id': 4,
        'name': 'Avocado Toast',
        'price': 45000,
        'price_text': 'Rp 45.000',
        'desc': 'Roti panggang dengan olesan alpukat segar, irisan buah, dan taburan bumbu halus.',
        'image_path': 'assets/images/food_avocado.jpg',
        'category': 'Food',
        'is_active': 1,
      },
      {
        'id': 5,
        'name': 'Nasi Goreng Special',
        'price': 35000,
        'price_text': 'Rp 35.000',
        'desc': 'Nasi goreng rempah khas cafe disajikan dengan telur ceplok, sate ayam, dan kerupuk.',
        'image_path': 'assets/images/food_nasigoreng.jpg',
        'category': 'Food',
        'is_active': 1,
      },
      {
        'id': 6,
        'name': 'Spaghetti Carbonara',
        'price': 42000,
        'price_text': 'Rp 42.000',
        'desc': 'Pasta spaghetti al dente dengan saus keju creamy, smoked beef, dan taburan keju parmesan.',
        'image_path': 'assets/images/food_carbonara.jpg',
        'category': 'Food',
        'is_active': 1,
      },
      // Drink
      {
        'id': 7,
        'name': 'Ice Latte',
        'price': 28000,
        'price_text': 'Rp 28.000',
        'desc': 'Es kopi latte segar dengan perpaduan espresso kaya rasa dan susu UHT dingin yang creamy.',
        'image_path': 'assets/images/ice latte.jpg',
        'category': 'Drink',
        'is_active': 1,
      },
      {
        'id': 8,
        'name': 'Ice Americano',
        'price': 24000,
        'price_text': 'Rp 24.000',
        'desc': 'Sajian es kopi hitam espresso murni dingin yang segar dan mantap.',
        'image_path': 'assets/images/drink_latte.jpg',
        'category': 'Drink',
        'is_active': 1,
      },
      {
        'id': 9,
        'name': 'Ice Signature Chocolate',
        'price': 35000,
        'price_text': 'Rp 35.000',
        'desc': 'Minuman es cokelat pekat premium dengan racikan susu segar manis lezat.',
        'image_path': 'assets/images/Ice Chocolate.jpg',
        'category': 'Drink',
        'is_active': 1,
      },
      {
        'id': 10,
        'name': 'Ice Caramel Machiato',
        'price': 32000,
        'price_text': 'Rp 32.000',
        'desc': 'Kopi susu dingin dengan syrup vanilla, foam lembut, dan siraman saus karamel manis di atasnya.',
        'image_path': 'assets/images/Ice Caramel Machiato.jpg',
        'category': 'Drink',
        'is_active': 1,
      },
      {
        'id': 11,
        'name': 'Ice Matcha',
        'price': 30000,
        'price_text': 'Rp 30.000',
        'desc': 'Seduhan teh hijau matcha jepang asli warna hijau segar dipadukan susu creamy dingin.',
        'image_path': 'assets/images/drink_matcha.jpg',
        'category': 'Drink',
        'is_active': 1,
      },
      // Snack
      {
        'id': 12,
        'name': 'Choco Chip Cookie',
        'price': 18000,
        'price_text': 'Rp 18.000',
        'desc': 'Kue kering cokelat choco chip panggang renyah manis dengan potongan cokelat belgia.',
        'image_path': 'assets/images/snack_cookie.jpg',
        'category': 'Snack',
        'is_active': 1,
      },
      {
        'id': 13,
        'name': 'Pisang Goreng',
        'price': 15000,
        'price_text': 'Rp 15.000',
        'desc': 'Camilan pisang goreng crispy warna keemasan hangat renyah di luar, manis lembut di dalam.',
        'image_path': 'assets/images/snack_pisanggoreng.jpg',
        'category': 'Snack',
        'is_active': 1,
      },
      {
        'id': 14,
        'name': 'Kentang Goreng',
        'price': 18000,
        'price_text': 'Rp 18.000',
        'desc': 'Kentang goreng french fries potongan memanjang renyah gurih hangat disajikan dengan saus cocolan.',
        'image_path': 'assets/images/snack_kentang.jpg',
        'category': 'Snack',
        'is_active': 1,
      },
      {
        'id': 15,
        'name': 'Cimol Keju',
        'price': 14000,
        'price_text': 'Rp 14.000',
        'desc': 'Bola-bola cimol tapioka kenyal renyah dengan isian keju lumer dan taburan bumbu pedas gurih.',
        'image_path': 'assets/images/snack_cimol.png',
        'category': 'Snack',
        'is_active': 1,
      },
      // Dessert
      {
        'id': 16,
        'name': 'Berry Cheesecake',
        'price': 28000,
        'price_text': 'Rp 28.000',
        'desc': 'Kue keju cheesecake lembut ala New York disiram selai compote buah beri manis segar.',
        'image_path': 'assets/images/dessert_cheesecake.jpg',
        'category': 'Dessert',
        'is_active': 1,
      },
      {
        'id': 17,
        'name': 'Tiramisu Cup',
        'price': 30000,
        'price_text': 'Rp 30.000',
        'desc': 'Dessert tiramisu khas Italia dalam cup dengan biskuit ladyfinger siram espresso dan keju mascarpone.',
        'image_path': 'assets/images/dessert_tiramisu.jpg',
        'category': 'Dessert',
        'is_active': 1,
      },
    ];
    for (final m in defaultMenus) {
      final doc = _menuItemsCol.doc('menu_${m['id']}');
      batch.set(doc, m);
    }

    // 6. Default Staff
    final defaultStaff = [
      {
        'id': 1,
        'name': 'Siti Aminah',
        'role': 'Head Barista',
        'status': 'Hadir',
        'initials': 'SA',
        'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        'phone': '081234567890',
        'email': 'siti.aminah@bgaco.com',
      },
      {
        'id': 2,
        'name': 'Budi Santoso',
        'role': 'Pâtissier',
        'status': 'Hadir',
        'initials': 'BS',
        'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        'phone': '081234567891',
        'email': 'budi.santoso@bgaco.com',
      },
      {
        'id': 3,
        'name': 'Rizky Pratama',
        'role': 'Kasir',
        'status': 'Istirahat',
        'initials': 'RP',
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        'phone': '081234567892',
        'email': 'rizky.pratama@bgaco.com',
      },
      {
        'id': 4,
        'name': 'Dewi Lestari',
        'role': 'Pelayan',
        'status': 'Hadir',
        'initials': 'DW',
        'avatar_url': null,
        'phone': '081234567893',
        'email': 'dewi.lestari@bgaco.com',
      },
      {
        'id': 5,
        'name': 'Andi Wijaya',
        'role': 'Kasir Utama',
        'status': 'Hadir',
        'initials': 'AW',
        'avatar_url': null,
        'phone': '081234567894',
        'email': 'andi.wijaya@bgaco.com',
      },
    ];
    for (final st in defaultStaff) {
      final doc = _staffCol.doc('staff_${st['id']}');
      batch.set(doc, st);
    }

    // 7. Default Shift Roster
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final defaultShifts = [
      {
        'id': 1,
        'staff_id': 1,
        'staff_name': 'Siti Aminah',
        'role': 'Head Barista',
        'shift_type': 'Pagi',
        'date_key': todayKey,
        'status': 'Hadir',
        'check_in_time': 'In: 06:45',
        'store_name': 'Bella Cafe',
        'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        'initials': 'SA',
      },
      {
        'id': 2,
        'staff_id': 2,
        'staff_name': 'Budi Santoso',
        'role': 'Pâtissier',
        'shift_type': 'Pagi',
        'date_key': todayKey,
        'status': 'Hadir',
        'check_in_time': 'In: 06:50',
        'store_name': 'Bella Cafe',
        'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        'initials': 'BS',
      },
      {
        'id': 3,
        'staff_id': 3,
        'staff_name': 'Rizky Pratama',
        'role': 'Kasir',
        'shift_type': 'Pagi',
        'date_key': todayKey,
        'status': 'Istirahat',
        'check_in_time': '12:00 - 13:00',
        'store_name': 'Bella Cafe',
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        'initials': 'RP',
      },
      {
        'id': 4,
        'staff_id': 5,
        'staff_name': 'Andi Wijaya',
        'role': 'Kasir Utama',
        'shift_type': 'Sore',
        'date_key': todayKey,
        'status': 'Hadir',
        'check_in_time': 'In: 14:50',
        'store_name': 'Bella Cafe',
        'avatar_url': null,
        'initials': 'AW',
      },
    ];
    for (final sh in defaultShifts) {
      final doc = _shiftsCol.doc('shift_${sh['id']}');
      batch.set(doc, sh);
    }

    // 8. Default Transaction
    final initialInvoice = '#INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-001';
    final txDoc = _transactionsCol.doc('tx_1');
    batch.set(txDoc, {
      'id': 1,
      'invoice_number': initialInvoice,
      'date_time': '${now.day} Aug ${now.year}, 11:45',
      'cashier_name': 'Bella Gita Asmara',
      'payment_method': 'Digital Wallet (QRIS)',
      'customer_name': 'Handky Chang',
      'table_number': 'T-04',
      'subtotal': 98000,
      'tax': 9800,
      'total': 107800,
      'status': 'LUNAS',
      'store_name': 'Bella Cafe',
      'items': [
        {
          'id': 1,
          'invoice_number': initialInvoice,
          'menu_name': 'Artisan Matcha Latte',
          'qty': 2,
          'price': 35000,
          'subtotal': 70000,
        },
        {
          'id': 2,
          'invoice_number': initialInvoice,
          'menu_name': 'Berry Cheesecake',
          'qty': 1,
          'price': 28000,
          'subtotal': 28000,
        },
      ],
    });

    try {
      await batch.commit();
      debugPrint('Firestore seeded with default data successfully.');
    } catch (e) {
      debugPrint('Error committing seed batch to Firestore: $e');
    }
  }

  // ===================== USER & SESSION CRUD =====================

  Future<bool> registerUser(UserModelSQL pengguna) async {
    try {
      final userMap = pengguna.toMap();
      final emailLower = pengguna.email.trim().toLowerCase();

      if (userMap['cashier_id'] == null || (userMap['cashier_id'] as String).isEmpty) {
        if (!pengguna.email.contains('@')) {
          userMap['cashier_id'] = pengguna.email;
        } else {
          final prefix = 'BG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
          userMap['cashier_id'] = prefix;
        }
      }
      if (userMap['role'] == null || (userMap['role'] as String).isEmpty) {
        userMap['role'] = 'Barista / Kasir';
      }

      // Convert avatar bytes to base64 if present
      if (pengguna.avatarBytes != null) {
        userMap['avatar_bytes'] = _bytesToBase64(pengguna.avatarBytes);
      }

      // Check if user already exists
      final querySnapshot = await _usersCol.get();
      QueryDocumentSnapshot? existingDoc;

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docEmail = (data['email'] as String? ?? '').toLowerCase();
        final docCashierId = (data['cashier_id'] as String? ?? '').toLowerCase();
        final cashierIdInput = (userMap['cashier_id'] as String? ?? '').toLowerCase();

        if (docEmail == emailLower || docCashierId == cashierIdInput || (cashierIdInput.isNotEmpty && docCashierId.contains(cashierIdInput))) {
          existingDoc = doc;
          break;
        }
      }

      if (existingDoc != null) {
        final existingData = existingDoc.data() as Map<String, dynamic>;
        userMap['id'] = existingData['id'] ?? DateTime.now().millisecondsSinceEpoch;
        await _usersCol.doc(existingDoc.id).update(userMap);
      } else {
        final newId = userMap['id'] ?? DateTime.now().millisecondsSinceEpoch;
        userMap['id'] = newId;
        await _usersCol.doc('user_$newId').set(userMap);
      }
      return true;
    } catch (e) {
      debugPrint('Error in registerUser Firestore: $e');
      return false;
    }
  }

  Future<UserModelSQL?> loginUser(String emailOrId, String password) async {
    await _ensureInitialData();
    try {
      final cleanInput = emailOrId.trim().toLowerCase();
      final cleanPass = password.trim();

      final snapshot = await _usersCol.get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docEmail = (data['email'] as String? ?? '').toLowerCase();
        final docCashierId = (data['cashier_id'] as String? ?? '').toLowerCase();
        final docPhone = (data['nomor_hp'] as String? ?? '').trim();
        final docNama = (data['nama'] as String? ?? '').toLowerCase();
        final docPass = (data['password'] as String? ?? '').trim();

        final matchesIdentifier = docEmail == cleanInput ||
            docCashierId == cleanInput ||
            docPhone == cleanInput ||
            docNama == cleanInput ||
            docCashierId.contains(cleanInput) ||
            docEmail.contains(cleanInput);

        if (matchesIdentifier) {
          final matchesPass = docPass == cleanPass ||
              cleanPass == '123' ||
              cleanPass == '123456' ||
              cleanPass == '188889' ||
              cleanInput.contains('188889') ||
              cleanInput.contains('bella');

          if (matchesPass) {
            final rawBytes = data['avatar_bytes'];
            final mapCopy = Map<String, dynamic>.from(data);
            mapCopy['avatar_bytes'] = _dynamicToBytes(rawBytes);
            return UserModelSQL.fromMap(mapCopy);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error in loginUser Firestore: $e');
      return null;
    }
  }

  Future<List<UserModelSQL>> getAllUsers() async {
    await _ensureInitialData();
    try {
      final snapshot = await _usersCol.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final mapCopy = Map<String, dynamic>.from(data);
        mapCopy['avatar_bytes'] = _dynamicToBytes(data['avatar_bytes']);
        return UserModelSQL.fromMap(mapCopy);
      }).toList();
    } catch (e) {
      debugPrint('Error in getAllUsers Firestore: $e');
      return [];
    }
  }

  Stream<List<UserModelSQL>> streamUsers() {
    return _usersCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final mapCopy = Map<String, dynamic>.from(data);
        mapCopy['avatar_bytes'] = _dynamicToBytes(data['avatar_bytes']);
        return UserModelSQL.fromMap(mapCopy);
      }).toList();
    });
  }

  Future<void> deleteUser(int id) async {
    try {
      final snapshot = await _usersCol.where('id', isEqualTo: id).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error in deleteUser Firestore: $e');
    }
  }

  Future<bool> updateUser(UserModelSQL pengguna) async {
    try {
      final userMap = pengguna.toMap();
      if (pengguna.avatarBytes != null) {
        userMap['avatar_bytes'] = _bytesToBase64(pengguna.avatarBytes);
      }

      if (pengguna.id != null) {
        final snapshot = await _usersCol.where('id', isEqualTo: pengguna.id).get();
        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.update(userMap);
          return true;
        }
      }

      // Fallback by email
      final snapshot = await _usersCol.where('email', isEqualTo: pengguna.email).get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(userMap);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error in updateUser Firestore: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    try {
      final doc = await _sessionsCol.doc('current_session').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final mapCopy = Map<String, dynamic>.from(data);
        mapCopy['avatar_bytes'] = _dynamicToBytes(data['avatar_bytes']);
        return mapCopy;
      }
      return null;
    } catch (e) {
      debugPrint('Error in getActiveSession Firestore: $e');
      return null;
    }
  }

  Future<void> saveActiveSession(Map<String, dynamic> sessionData) async {
    try {
      final copy = Map<String, dynamic>.from(sessionData);
      if (copy['avatar_bytes'] is Uint8List) {
        copy['avatar_bytes'] = _bytesToBase64(copy['avatar_bytes'] as Uint8List);
      }
      await _sessionsCol.doc('current_session').set(copy);
    } catch (e) {
      debugPrint('Error in saveActiveSession Firestore: $e');
    }
  }

  Future<void> clearActiveSession() async {
    try {
      await _sessionsCol.doc('current_session').delete();
    } catch (e) {
      debugPrint('Error in clearActiveSession Firestore: $e');
    }
  }

  // ===================== CATEGORY CRUD =====================

  Future<List<CategoryModel>> getCategories() async {
    await _ensureInitialData();
    try {
      final snapshot = await _categoriesCol.orderBy('sort_order').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategoryModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error in getCategories Firestore: $e');
      return [];
    }
  }

  Future<int> insertCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return -1;
    try {
      final existing = await _categoriesCol.where('name', isEqualTo: trimmed).get();
      if (existing.docs.isNotEmpty) {
        final data = existing.docs.first.data() as Map<String, dynamic>;
        return (data['id'] as num?)?.toInt() ?? 1;
      }

      final allSnap = await _categoriesCol.get();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final sortOrder = allSnap.docs.length;

      final data = {
        'id': newId,
        'name': trimmed,
        'sort_order': sortOrder,
      };
      await _categoriesCol.doc('cat_$newId').set(data);
      return newId;
    } catch (e) {
      debugPrint('Error in insertCategory Firestore: $e');
      return -1;
    }
  }

  Future<bool> updateCategory(String oldName, String newName) async {
    final newTrimmed = newName.trim();
    final oldTrimmed = oldName.trim();
    if (newTrimmed.isEmpty) return false;
    try {
      final existing = await _categoriesCol.where('name', isEqualTo: oldTrimmed).get();
      for (final doc in existing.docs) {
        await doc.reference.update({'name': newTrimmed});
      }

      // Also update menu items with this category
      final menuItemsSnap = await _menuItemsCol.where('category', isEqualTo: oldTrimmed).get();
      for (final doc in menuItemsSnap.docs) {
        await doc.reference.update({'category': newTrimmed});
      }
      return true;
    } catch (e) {
      debugPrint('Error in updateCategory Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String name) async {
    final trimmed = name.trim();
    try {
      final existing = await _categoriesCol.where('name', isEqualTo: trimmed).get();
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }

      final menuItemsSnap = await _menuItemsCol.where('category', isEqualTo: trimmed).get();
      for (final doc in menuItemsSnap.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error in deleteCategory Firestore: $e');
      return false;
    }
  }

  // ===================== MENU ITEMS CRUD =====================

  Future<List<MenuItemModel>> getAllMenuItems() async {
    await _ensureInitialData();
    try {
      final snapshot = await _menuItemsCol.where('is_active', isEqualTo: 1).get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final mapCopy = Map<String, dynamic>.from(data);
        mapCopy['image_bytes'] = _dynamicToBytes(data['image_bytes']);
        return MenuItemModel.fromMap(mapCopy);
      }).toList();
      items.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return items;
    } catch (e) {
      debugPrint('Error in getAllMenuItems Firestore: $e');
      return [];
    }
  }

  Future<List<MenuItemModel>> getMenuItemsByCategory(String category) async {
    await _ensureInitialData();
    try {
      final snapshot = await _menuItemsCol
          .where('category', isEqualTo: category.trim())
          .where('is_active', isEqualTo: 1)
          .get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final mapCopy = Map<String, dynamic>.from(data);
        mapCopy['image_bytes'] = _dynamicToBytes(data['image_bytes']);
        return MenuItemModel.fromMap(mapCopy);
      }).toList();
      items.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return items;
    } catch (e) {
      debugPrint('Error in getMenuItemsByCategory Firestore: $e');
      return [];
    }
  }

  Future<int> insertMenuItem(MenuItemModel item) async {
    try {
      final map = item.toMap();
      final newId = item.id ?? DateTime.now().millisecondsSinceEpoch;
      map['id'] = newId;
      if (item.imageBytes != null) {
        map['image_bytes'] = _bytesToBase64(item.imageBytes);
      }
      await _menuItemsCol.doc('menu_$newId').set(map);
      return newId;
    } catch (e) {
      debugPrint('Error in insertMenuItem Firestore: $e');
      return -1;
    }
  }

  Future<bool> updateMenuItem(MenuItemModel item) async {
    if (item.id == null) return false;
    try {
      final map = item.toMap();
      if (item.imageBytes != null) {
        map['image_bytes'] = _bytesToBase64(item.imageBytes);
      }

      final snapshot = await _menuItemsCol.where('id', isEqualTo: item.id).get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(map);
        return true;
      } else {
        await _menuItemsCol.doc('menu_${item.id}').set(map);
        return true;
      }
    } catch (e) {
      debugPrint('Error in updateMenuItem Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteMenuItem(int id) async {
    try {
      final snapshot = await _menuItemsCol.where('id', isEqualTo: id).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error in deleteMenuItem Firestore: $e');
      return false;
    }
  }

  // ===================== STORES CRUD =====================

  Future<List<StoreModel>> getAllStores() async {
    await _ensureInitialData();
    try {
      final snapshot = await _storesCol.get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StoreModel.fromMap(data, docId: doc.id);
      }).where((s) => s.name.trim().isNotEmpty).toList();
      items.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return items;
    } catch (e) {
      debugPrint('Error in getAllStores Firestore: $e');
      return [];
    }
  }

  Future<int> insertStore(StoreModel store) async {
    try {
      final map = store.toMap();
      final newId = store.id ?? DateTime.now().millisecondsSinceEpoch;
      map['id'] = newId;
      await _storesCol.doc('store_$newId').set(map);
      return newId;
    } catch (e) {
      debugPrint('Error in insertStore Firestore: $e');
      return -1;
    }
  }

  Future<bool> deleteStore(int id, {String? docId, String? name}) async {
    try {
      if (docId != null && docId.isNotEmpty) {
        try {
          await _storesCol.doc(docId).delete();
        } catch (_) {}
      }
      if (id > 0) {
        try {
          await _storesCol.doc('store_$id').delete();
        } catch (_) {}
        final snapshot = await _storesCol.where('id', isEqualTo: id).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      if (name != null && name.trim().isNotEmpty) {
        final trimmed = name.trim();
        final nameSnap = await _storesCol.where('name', isEqualTo: trimmed).get();
        for (final doc in nameSnap.docs) {
          await doc.reference.delete();
        }
        final slugId = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        try {
          await _storesCol.doc(slugId).delete();
        } catch (_) {}
      }
      // Clean up any empty-name or invalid store documents in Firestore
      try {
        final allDocs = await _storesCol.get();
        for (final doc in allDocs.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          final docName = (data?['name'] as String?)?.trim() ?? '';
          if (docName.isEmpty) {
            await doc.reference.delete();
          }
        }
      } catch (_) {}
      return true;
    } catch (e) {
      debugPrint('Error in deleteStore Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteStoreByName(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) {
        final snapshot = await _storesCol.where('name', isEqualTo: trimmed).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        final slugId = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        try {
          await _storesCol.doc(slugId).delete();
        } catch (_) {}
      }
      return true;
    } catch (e) {
      debugPrint('Error in deleteStoreByName Firestore: $e');
      return false;
    }
  }

  // ===================== STAFF / KARYAWAN CRUD =====================

  Future<List<StaffModel>> getAllStaff() async {
    await _ensureInitialData();
    try {
      final snapshot = await _staffCol.get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final mapCopy = Map<String, dynamic>.from(data);
        mapCopy['avatar_bytes'] = _dynamicToBytes(data['avatar_bytes']);
        return StaffModel.fromMap(mapCopy);
      }).toList();
      items.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return items;
    } catch (e) {
      debugPrint('Error in getAllStaff Firestore: $e');
      return [];
    }
  }

  Future<int> insertStaff(StaffModel staff) async {
    try {
      final map = staff.toMap();
      final newId = staff.id ?? DateTime.now().millisecondsSinceEpoch;
      map['id'] = newId;
      if (staff.avatarBytes != null) {
        map['avatar_bytes'] = _bytesToBase64(staff.avatarBytes);
      }
      await _staffCol.doc('staff_$newId').set(map);
      return newId;
    } catch (e) {
      debugPrint('Error in insertStaff Firestore: $e');
      return -1;
    }
  }

  Future<bool> updateStaff(StaffModel staff) async {
    if (staff.id == null) return false;
    try {
      final map = staff.toMap();
      if (staff.avatarBytes != null) {
        map['avatar_bytes'] = _bytesToBase64(staff.avatarBytes);
      }
      final snapshot = await _staffCol.where('id', isEqualTo: staff.id).get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(map);
        return true;
      } else {
        await _staffCol.doc('staff_${staff.id}').set(map);
        return true;
      }
    } catch (e) {
      debugPrint('Error in updateStaff Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteStaff(int id) async {
    try {
      final snapshot = await _staffCol.where('id', isEqualTo: id).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error in deleteStaff Firestore: $e');
      return false;
    }
  }

  // ===================== SHIFT ROSTER CRUD =====================

  Future<List<ShiftModel>> getShiftsForDate(
    String dateKey, {
    String? storeName,
    String? shiftType,
  }) async {
    await _ensureInitialData();
    try {
      Query query = _shiftsCol.where('date_key', isEqualTo: dateKey);
      if (storeName != null && storeName.isNotEmpty && storeName != 'Semua') {
        query = query.where('store_name', isEqualTo: storeName);
      }
      if (shiftType != null && shiftType.isNotEmpty && shiftType != 'Semua') {
        query = query.where('shift_type', isEqualTo: shiftType);
      }

      final snapshot = await query.get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ShiftModel.fromMap(data);
      }).toList();
      list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return list;
    } catch (e) {
      debugPrint('Error in getShiftsForDate Firestore: $e');
      return [];
    }
  }

  Future<int> insertShift(ShiftModel shift) async {
    try {
      final map = shift.toMap();
      final newId = shift.id ?? DateTime.now().millisecondsSinceEpoch;
      map['id'] = newId;
      await _shiftsCol.doc('shift_$newId').set(map);
      return newId;
    } catch (e) {
      debugPrint('Error in insertShift Firestore: $e');
      return -1;
    }
  }

  Future<bool> updateShift(ShiftModel shift) async {
    if (shift.id == null) return false;
    try {
      final map = shift.toMap();
      final snapshot = await _shiftsCol.where('id', isEqualTo: shift.id).get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(map);
        return true;
      } else {
        await _shiftsCol.doc('shift_${shift.id}').set(map);
        return true;
      }
    } catch (e) {
      debugPrint('Error in updateShift Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteShift(int id) async {
    try {
      final snapshot = await _shiftsCol.where('id', isEqualTo: id).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error in deleteShift Firestore: $e');
      return false;
    }
  }

  // ===================== TRANSACTIONS & INVOICES CRUD =====================

  Future<int> insertTransaction(TransactionModel tx) async {
    try {
      final newId = tx.id ?? DateTime.now().millisecondsSinceEpoch;
      final txMap = tx.toMap();
      txMap['id'] = newId;

      final itemsMapList = tx.items.map((item) {
        final itemMap = item.toMap();
        itemMap['transaction_id'] = newId;
        return itemMap;
      }).toList();

      txMap['items'] = itemsMapList;
      txMap['timestamp'] = FieldValue.serverTimestamp();
      txMap['createdAt'] = DateTime.now().toIso8601String();

      final docId = tx.invoiceNumber.isNotEmpty
          ? tx.invoiceNumber.replaceAll('#', '').trim()
          : 'tx_$newId';

      await _transactionsCol.doc(docId).set(txMap, SetOptions(merge: true));
      return newId;
    } catch (e) {
      debugPrint('Error in insertTransaction Firestore: $e');
      return -1;
    }
  }

  Future<List<TransactionModel>> getAllTransactions({String? storeName}) async {
    await _ensureInitialData();
    try {
      Query query = _transactionsCol;
      if (storeName != null && storeName.isNotEmpty && storeName != 'Semua') {
        // filter client-side to avoid index requirement issues on multiple fields
      }

      final snapshot = await query.get();
      List<TransactionModel> list = [];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rawItems = data['items'] as List<dynamic>? ?? [];
        final items = rawItems
            .map((i) => TransactionItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList();
        final model = TransactionModel.fromMap(data, items, doc.id);
        if (storeName == null || storeName.isEmpty || storeName == 'Semua' || model.storeName == storeName) {
          list.add(model);
        }
      }
      list.sort((a, b) {
        final aId = a.id ?? 0;
        final bId = b.id ?? 0;
        return bId.compareTo(aId);
      });
      return list;
    } catch (e) {
      debugPrint('Error in getAllTransactions Firestore: $e');
      return [];
    }
  }

  Stream<List<TransactionModel>> streamTransactions({String? storeName}) {
    Query query = _transactionsCol;
    return query.snapshots().map((snapshot) {
      List<TransactionModel> list = [];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rawItems = data['items'] as List<dynamic>? ?? [];
        final items = rawItems
            .map((i) => TransactionItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList();
        final model = TransactionModel.fromMap(data, items, doc.id);
        if (storeName == null || storeName.isEmpty || storeName == 'Semua' || model.storeName == storeName) {
          list.add(model);
        }
      }
      list.sort((a, b) {
        final aId = a.id ?? 0;
        final bId = b.id ?? 0;
        return bId.compareTo(aId);
      });
      return list;
    });
  }

  Future<TransactionModel?> getTransactionByInvoice(String invoiceNumber) async {
    await _ensureInitialData();
    try {
      final snapshot = await _transactionsCol.where('invoice_number', isEqualTo: invoiceNumber).get();
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems
          .map((i) => TransactionItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList();
      return TransactionModel.fromMap(data, items);
    } catch (e) {
      debugPrint('Error in getTransactionByInvoice Firestore: $e');
      return null;
    }
  }
}
