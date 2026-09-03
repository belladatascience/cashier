import 'package:cashier/halaman1/database/database_helper.dart';
import 'package:cashier/halaman1/models/menu_item_model.dart';
import 'package:flutter/material.dart';

class MenuDataStore {
  static final MenuDataStore instance = MenuDataStore._internal();
  MenuDataStore._internal();

  bool _isInitialized = false;

  final ValueNotifier<List<String>> categoriesNotifier =
      ValueNotifier<List<String>>(['Food', 'Drink', 'Snack', 'Dessert']);

  final ValueNotifier<Map<String, List<Map<String, dynamic>>>>
  menuDataNotifier = ValueNotifier<Map<String, List<Map<String, dynamic>>>>({
    'Food': [],
    'Drink': [],
    'Snack': [],
    'Dessert': [],
  });

  List<String> get categories => categoriesNotifier.value;
  Map<String, List<Map<String, dynamic>>> get categoryDataMap =>
      menuDataNotifier.value;

  Future<void> initFromDatabase() async {
    if (_isInitialized) return;
    await reloadFromDatabase();
    _isInitialized = true;
  }

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

      categoriesNotifier.value = loadedCategories;
      menuDataNotifier.value = map;
    } catch (e) {
      debugPrint('Error loading MenuDataStore from DB: $e');
    }
  }

  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    await DataBaseHelper().insertCategory(trimmed);
    await reloadFromDatabase();
  }

  Future<void> renameCategory(String oldName, String newName) async {
    final oldTrimmed = oldName.trim();
    final newTrimmed = newName.trim();
    if (newTrimmed.isEmpty || oldTrimmed == newTrimmed) return;

    await DataBaseHelper().updateCategory(oldTrimmed, newTrimmed);
    await reloadFromDatabase();
  }

  Future<void> deleteCategory(String name) async {
    final trimmed = name.trim();
    await DataBaseHelper().deleteCategory(trimmed);
    await reloadFromDatabase();
  }

  Future<void> addMenuItem(
    String categoryName,
    Map<String, dynamic> item,
  ) async {
    final model = MenuItemModel(
      name: item['name'] as String,
      price: (item['price'] is int)
          ? item['price'] as int
          : int.tryParse(
                  item['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0,
      priceText: item['priceText'] as String? ?? 'Rp ${item['price']}',
      desc: item['desc'] as String? ?? '',
      imagePath: item['image'] is String ? item['image'] as String : null,
      imageBytes: item['image'] is! String ? item['image'] : null,
      category: categoryName.trim(),
    );

    await DataBaseHelper().insertMenuItem(model);
    await reloadFromDatabase();
  }

  Future<void> updateMenuItem(int id, Map<String, dynamic> item) async {
    final model = MenuItemModel(
      id: id,
      name: item['name'] as String,
      price: (item['price'] is int)
          ? item['price'] as int
          : int.tryParse(
                  item['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0,
      priceText: item['priceText'] as String? ?? 'Rp ${item['price']}',
      desc: item['desc'] as String? ?? '',
      imagePath: item['image'] is String ? item['image'] as String : null,
      imageBytes: item['image'] is! String ? item['image'] : null,
      category: (item['category'] as String?)?.trim() ?? 'Food',
    );

    await DataBaseHelper().updateMenuItem(model);
    await reloadFromDatabase();
  }

  Future<void> deleteMenuItem(int id) async {
    await DataBaseHelper().deleteMenuItem(id);
    await reloadFromDatabase();
  }
}
