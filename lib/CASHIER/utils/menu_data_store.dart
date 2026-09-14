import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashier/CASHIER/database/database_helper.dart';
import 'package:cashier/CASHIER/models/menu_item_model.dart';
import 'package:flutter/foundation.dart';

class MenuDataStore {
  static final MenuDataStore instance = MenuDataStore._internal();
  MenuDataStore._internal();

  bool _isInitialized = false;
  StreamSubscription? _categorySubscription;
  StreamSubscription? _menuSubscription;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<List<String>> categoriesNotifier =
      ValueNotifier<List<String>>(['Food', 'Drink', 'Snack', 'Dessert']);

  final ValueNotifier<Map<String, List<Map<String, dynamic>>>>
  menuDataNotifier = ValueNotifier<Map<String, List<Map<String, dynamic>>>>({
    'Food': [],
    'Drink': [],
    'Snack': [],
    'Dessert': [],
  });

  List<String> get categories => List<String>.from(categoriesNotifier.value);
  Map<String, List<Map<String, dynamic>>> get categoryDataMap =>
      menuDataNotifier.value;

  /// Daftar Menu Default Kaya & Lengkap untuk setiap Kategori
  static final Map<String, List<Map<String, dynamic>>> _defaultMenuSeed = {
    'Food': [
      {
        'id': 101,
        'name': 'Sourdough Artisan Loaf',
        'price': 38000,
        'priceText': 'Rp 38.000',
        'desc': 'Roti artisan sourdough klasik berkulit renyah garing dengan bagian dalam yang empuk.',
        'image': 'assets/images/food_sourdough.jpg',
        'category': 'Food',
      },
      {
        'id': 102,
        'name': 'Butter French Croissant',
        'price': 25000,
        'priceText': 'Rp 25.000',
        'desc': 'Pastry croissant khas Prancis yang renyah berlayer dengan aroma mentega gurih.',
        'image': 'assets/images/food_croissant.jpg',
        'category': 'Food',
      },
      {
        'id': 103,
        'name': 'Berry Custard Tart',
        'price': 35000,
        'priceText': 'Rp 35.000',
        'desc': 'Kue tart manis dengan topping buah beri segar dan krim custard lembut.',
        'image': 'assets/images/food_tart.jpg',
        'category': 'Food',
      },
      {
        'id': 104,
        'name': 'Avocado Sunny Toast',
        'price': 45000,
        'priceText': 'Rp 45.000',
        'desc': 'Roti panggang dengan olesan alpukat segar, irisan tomat ceri, dan taburan chia seed.',
        'image': 'assets/images/food_avocado.jpg',
        'category': 'Food',
      },
      {
        'id': 105,
        'name': 'Smoked Beef Panini',
        'price': 42000,
        'priceText': 'Rp 42.000',
        'desc': 'Roti panini hangat dengan isian daging sapi asap premium dan keju mozzarella leleh.',
        'image': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=300&q=80',
        'category': 'Food',
      },
      {
        'id': 106,
        'name': 'Spaghetti Carbonara Cream',
        'price': 48000,
        'priceText': 'Rp 48.000',
        'desc': 'Pasta spaghetti creamy dengan taburan keju parmesan dan smoked beef crispy.',
        'image': 'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&w=300&q=80',
        'category': 'Food',
      },
    ],
    'Drink': [
      {
        'id': 201,
        'name': 'Signature BGA Latte',
        'price': 32000,
        'priceText': 'Rp 32.000',
        'desc': 'Kopi espresso house blend dipadu susu steam lembut dan sentuhan gula aren spesial.',
        'image': 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
      {
        'id': 202,
        'name': 'Classic Americano',
        'price': 24000,
        'priceText': 'Rp 24.000',
        'desc': 'Double shot espresso arabika pilihan disajikan hangat atau dingin menyegarkan.',
        'image': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
      {
        'id': 203,
        'name': 'Vanilla Sweet Cream Cold Brew',
        'price': 35000,
        'priceText': 'Rp 35.000',
        'desc': 'Kopi seduh dingin selama 12 jam dengan topping krim vanila manis lembut.',
        'image': 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
      {
        'id': 204,
        'name': 'Matcha Green Tea Latte',
        'price': 34000,
        'priceText': 'Rp 34.000',
        'desc': 'Bubuk matcha murni Jepang berpadu susu segar menghasilkan rasa creamy menenangkan.',
        'image': 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
      {
        'id': 205,
        'name': 'Caramel Macchiato Velvet',
        'price': 36000,
        'priceText': 'Rp 36.000',
        'desc': 'Espresso kaya rasa berpadu sirup karamel bakar dan susu segar berbusa lembut.',
        'image': 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
      {
        'id': 206,
        'name': 'Fresh Peach Lemonade',
        'price': 26000,
        'priceText': 'Rp 26.000',
        'desc': 'Minuman segar perasan lemon asli berpadu sari buah persik manis dan soda.',
        'image': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
      {
        'id': 207,
        'name': 'Earl Grey Milk Tea',
        'price': 28000,
        'priceText': 'Rp 28.000',
        'desc': 'Teh hitam aromatik berpadu susu segar dan aroma bunga bergamot yang khas.',
        'image': 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=300&q=80',
        'category': 'Drink',
      },
    ],
    'Snack': [
      {
        'id': 301,
        'name': 'Truffle French Fries',
        'price': 28000,
        'priceText': 'Rp 28.000',
        'desc': 'Kentang goreng renyah dengan minyak truffle aromatik dan taburan keju parmesan.',
        'image': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=300&q=80',
        'category': 'Snack',
      },
      {
        'id': 302,
        'name': 'Crispy Chicken Popcorn',
        'price': 32000,
        'priceText': 'Rp 32.000',
        'desc': 'Potongan ayam fillet krispi gurih dengan saus cocolan thousand island.',
        'image': 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=300&q=80',
        'category': 'Snack',
      },
      {
        'id': 303,
        'name': 'Cheesy Nachos Supreme',
        'price': 35000,
        'priceText': 'Rp 35.000',
        'desc': 'Keripik jagung renyah berbalut keju leleh hangat, saus salsa, dan daging cincang.',
        'image': 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?auto=format&fit=crop&w=300&q=80',
        'category': 'Snack',
      },
      {
        'id': 304,
        'name': 'Garlic Butter Breadsticks',
        'price': 22000,
        'priceText': 'Rp 22.000',
        'desc': 'Roti stik renyah beraroma bawang putih wangi dan taburan parsley.',
        'image': 'https://images.unsplash.com/photo-1549611016-3a70d82b5040?auto=format&fit=crop&w=300&q=80',
        'category': 'Snack',
      },
      {
        'id': 305,
        'name': 'Crispy Onion Rings',
        'price': 24000,
        'priceText': 'Rp 24.000',
        'desc': 'Irisan bawang bombay manis berlapis tepung bumbu renyah keemasan.',
        'image': 'https://images.unsplash.com/photo-1639024471285-05c285cc1508?auto=format&fit=crop&w=300&q=80',
        'category': 'Snack',
      },
    ],
    'Dessert': [
      {
        'id': 401,
        'name': 'Classic Tiramisu Cup',
        'price': 35000,
        'priceText': 'Rp 35.000',
        'desc': 'Dessert khas Italia berlayer ladyfingers kopi, krim mascarpone, dan bubuk kakao.',
        'image': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=300&q=80',
        'category': 'Dessert',
      },
      {
        'id': 402,
        'name': 'Molten Lava Chocolate Cake',
        'price': 38000,
        'priceText': 'Rp 38.000',
        'desc': 'Kue cokelat hangat dengan lelehan cokelat pekat di bagian dalamnya.',
        'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=300&q=80',
        'category': 'Dessert',
      },
      {
        'id': 403,
        'name': 'New York Baked Cheesecake',
        'price': 36000,
        'priceText': 'Rp 36.000',
        'desc': 'Kue keju panggang lembut dengan dasar biskuit renyah dan selai stroberi.',
        'image': 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=300&q=80',
        'category': 'Dessert',
      },
      {
        'id': 404,
        'name': 'Glazed Cinnamon Roll',
        'price': 26000,
        'priceText': 'Rp 26.000',
        'desc': 'Roti kayu manis empuk beraroma wangi dengan lelehan gula glaze lembut.',
        'image': 'https://images.unsplash.com/photo-1509365465985-25d11c17e812?auto=format&fit=crop&w=300&q=80',
        'category': 'Dessert',
      },
      {
        'id': 405,
        'name': 'Strawberry Choux Pastry',
        'price': 28000,
        'priceText': 'Rp 28.000',
        'desc': 'Kue sus renyah dengan isian krim diplomat vanila dan potongan stroberi segar.',
        'image': 'https://images.unsplash.com/photo-1612203985729-70726954388c?auto=format&fit=crop&w=300&q=80',
        'category': 'Dessert',
      },
    ],
  };

  /// Initialize menu and categories from Firebase
  Future<void> initFromDatabase() async {
    if (_isInitialized) return;
    await reloadFromDatabase();
    _startRealtimeListeners();
    _isInitialized = true;
  }

  /// Alias for initFromDatabase
  Future<void> initFromFirebase() async => initFromDatabase();

  /// Start real-time Firestore synchronization
  void _startRealtimeListeners() {
    try {
      _categorySubscription?.cancel();
      _menuSubscription?.cancel();

      // Listen to categories collection
      _categorySubscription = _firestore
          .collection('categories')
          .orderBy('sort_order')
          .snapshots()
          .listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            _syncFromSnapshots();
          }
        },
        onError: (e) => debugPrint('Firestore category stream error: $e'),
      );

      // Listen to menu_items collection
      _menuSubscription = _firestore
          .collection('menu_items')
          .where('is_active', isEqualTo: 1)
          .snapshots()
          .listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            _syncFromSnapshots();
          }
        },
        onError: (e) => debugPrint('Firestore menu stream error: $e'),
      );
    } catch (e) {
      debugPrint('Error attaching realtime menu listeners: $e');
    }
  }

  Future<void> _syncFromSnapshots() async {
    await reloadFromDatabase();
  }

  /// Reload data from Firebase Firestore / Local Database
  Future<void> reloadFromDatabase() async {
    try {
      final dbHelper = DataBaseHelper();
      final catList = await dbHelper.getCategories();
      final menuList = await dbHelper.getAllMenuItems();

      List<String> loadedCategories = catList.map((c) => c.name).toList();
      if (loadedCategories.isEmpty) {
        loadedCategories = ['Food', 'Drink', 'Snack', 'Dessert'];
        for (final c in loadedCategories) {
          await dbHelper.insertCategory(c);
        }
      }

      final Map<String, List<Map<String, dynamic>>> map = {};
      for (final cat in loadedCategories) {
        map[cat] = [];
      }

      for (final item in menuList) {
        if (!map.containsKey(item.category)) {
          map[item.category] = [];
          if (!loadedCategories.contains(item.category)) {
            loadedCategories.add(item.category);
          }
        }
        map[item.category]!.add(item.toLegacyMap());
      }

      // Pastikan setiap kategori standar terisi menu default jika masih kosong
      for (final defaultCat in _defaultMenuSeed.keys) {
        if (!map.containsKey(defaultCat)) {
          map[defaultCat] = [];
          if (!loadedCategories.contains(defaultCat)) {
            loadedCategories.add(defaultCat);
          }
        }
        if (map[defaultCat]!.isEmpty) {
          map[defaultCat] = List<Map<String, dynamic>>.from(_defaultMenuSeed[defaultCat]!);
          // Seed ke database secara background
          for (final item in _defaultMenuSeed[defaultCat]!) {
            final model = MenuItemModel(
              id: item['id'] as int?,
              name: item['name'] as String,
              price: item['price'] as int,
              priceText: item['priceText'] as String,
              desc: item['desc'] as String,
              imagePath: item['image'] as String,
              category: defaultCat,
            );
            dbHelper.insertMenuItem(model).catchError((_) => -1);
          }
        }
      }

      categoriesNotifier.value = List<String>.from(loadedCategories);
      menuDataNotifier.value = Map<String, List<Map<String, dynamic>>>.from(map);
    } catch (e) {
      debugPrint('Error loading MenuDataStore from Firebase: $e');
      // Fallback ke default seed jika terjadi error koneksi
      categoriesNotifier.value = ['Food', 'Drink', 'Snack', 'Dessert'];
      menuDataNotifier.value = Map<String, List<Map<String, dynamic>>>.from(_defaultMenuSeed);
    }
  }

  /// Add category to Firestore with instant optimistic UI update
  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    // 1. Update State Lokal secara instan (Optimistic UI)
    final currentCats = List<String>.from(categoriesNotifier.value);
    if (!currentCats.contains(trimmed)) {
      currentCats.add(trimmed);
    }
    final currentMap = Map<String, List<Map<String, dynamic>>>.from(menuDataNotifier.value);
    if (!currentMap.containsKey(trimmed)) {
      currentMap[trimmed] = [];
    }
    categoriesNotifier.value = currentCats;
    menuDataNotifier.value = currentMap;

    // 2. Simpan ke Firestore & Database Helper
    try {
      await DataBaseHelper().insertCategory(trimmed);
    } catch (e) {
      debugPrint('Error saving new category: $e');
    }
  }

  /// Rename category in Firestore with instant optimistic UI update
  Future<void> renameCategory(String oldName, String newName) async {
    final oldTrimmed = oldName.trim();
    final newTrimmed = newName.trim();
    if (newTrimmed.isEmpty || oldTrimmed == newTrimmed) return;

    final currentCats = List<String>.from(categoriesNotifier.value);
    final idx = currentCats.indexOf(oldTrimmed);
    if (idx != -1) {
      currentCats[idx] = newTrimmed;
    }
    final currentMap = Map<String, List<Map<String, dynamic>>>.from(menuDataNotifier.value);
    if (currentMap.containsKey(oldTrimmed)) {
      final items = currentMap.remove(oldTrimmed)!;
      for (final item in items) {
        item['category'] = newTrimmed;
      }
      currentMap[newTrimmed] = items;
    }
    categoriesNotifier.value = currentCats;
    menuDataNotifier.value = currentMap;

    try {
      await DataBaseHelper().updateCategory(oldTrimmed, newTrimmed);
    } catch (e) {
      debugPrint('Error renaming category: $e');
    }
  }

  /// Delete category from Firestore with instant optimistic UI update
  Future<void> deleteCategory(String name) async {
    final trimmed = name.trim();
    final currentCats = List<String>.from(categoriesNotifier.value);
    currentCats.remove(trimmed);

    final currentMap = Map<String, List<Map<String, dynamic>>>.from(menuDataNotifier.value);
    currentMap.remove(trimmed);

    categoriesNotifier.value = currentCats;
    menuDataNotifier.value = currentMap;

    try {
      await DataBaseHelper().deleteCategory(trimmed);
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  /// Add new menu item to Firestore with instant optimistic UI update
  Future<void> addMenuItem(
    String categoryName,
    Map<String, dynamic> item,
  ) async {
    final cat = categoryName.trim();
    final priceVal = (item['price'] is int)
        ? item['price'] as int
        : int.tryParse(item['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final newId = item['id'] ?? DateTime.now().millisecondsSinceEpoch;
    final itemMap = Map<String, dynamic>.from(item);
    itemMap['id'] = newId;
    itemMap['category'] = cat;
    itemMap['price'] = priceVal;
    itemMap['priceText'] = item['priceText'] ?? 'Rp ${priceVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    // 1. Update State Lokal secara instan
    final currentMap = Map<String, List<Map<String, dynamic>>>.from(menuDataNotifier.value);
    if (!currentMap.containsKey(cat)) {
      currentMap[cat] = [];
    }
    currentMap[cat] = List<Map<String, dynamic>>.from(currentMap[cat]!)..add(itemMap);
    menuDataNotifier.value = currentMap;

    // 2. Simpan ke Firestore & Database
    try {
      final model = MenuItemModel(
        id: newId is int ? newId : null,
        name: item['name'] as String,
        price: priceVal,
        priceText: itemMap['priceText'] as String,
        desc: item['desc'] as String? ?? '',
        imagePath: item['image'] is String ? item['image'] as String : null,
        imageBytes: item['image'] is! String ? item['image'] : null,
        category: cat,
      );
      await DataBaseHelper().insertMenuItem(model);
    } catch (e) {
      debugPrint('Error inserting menu item to Firestore: $e');
    }
  }

  /// Update existing menu item in Firestore with instant optimistic UI update
  Future<void> updateMenuItem(int id, Map<String, dynamic> item) async {
    final cat = (item['category'] as String?)?.trim() ?? 'Food';
    final priceVal = (item['price'] is int)
        ? item['price'] as int
        : int.tryParse(item['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final itemMap = Map<String, dynamic>.from(item);
    itemMap['id'] = id;
    itemMap['category'] = cat;
    itemMap['price'] = priceVal;

    // 1. Update State Lokal secara instan
    final currentMap = Map<String, List<Map<String, dynamic>>>.from(menuDataNotifier.value);
    if (currentMap.containsKey(cat)) {
      final list = List<Map<String, dynamic>>.from(currentMap[cat]!);
      final idx = list.indexWhere((it) => it['id'] == id || it['name'] == item['name']);
      if (idx != -1) {
        list[idx] = itemMap;
        currentMap[cat] = list;
        menuDataNotifier.value = currentMap;
      }
    }

    // 2. Simpan ke Firestore & Database
    try {
      final model = MenuItemModel(
        id: id,
        name: item['name'] as String,
        price: priceVal,
        priceText: item['priceText'] as String? ?? 'Rp $priceVal',
        desc: item['desc'] as String? ?? '',
        imagePath: item['image'] is String ? item['image'] as String : null,
        imageBytes: item['image'] is! String ? item['image'] : null,
        category: cat,
      );
      await DataBaseHelper().updateMenuItem(model);
    } catch (e) {
      debugPrint('Error updating menu item in Firestore: $e');
    }
  }

  /// Delete menu item from Firestore with instant optimistic UI update
  Future<void> deleteMenuItem(int id) async {
    final currentMap = Map<String, List<Map<String, dynamic>>>.from(menuDataNotifier.value);
    for (final cat in currentMap.keys) {
      final list = List<Map<String, dynamic>>.from(currentMap[cat]!);
      final beforeLen = list.length;
      list.removeWhere((it) => it['id'] == id);
      if (list.length != beforeLen) {
        currentMap[cat] = list;
        menuDataNotifier.value = currentMap;
        break;
      }
    }

    try {
      await DataBaseHelper().deleteMenuItem(id);
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
    }
  }

  void dispose() {
    _categorySubscription?.cancel();
    _menuSubscription?.cancel();
  }
}
