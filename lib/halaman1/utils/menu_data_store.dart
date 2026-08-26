import 'package:flutter/material.dart';

class MenuDataStore {
  static final MenuDataStore instance = MenuDataStore._internal();
  MenuDataStore._internal();

  final List<String> categories = ['Food', 'Drink', 'Snack', 'Dessert'];

  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Sourdough Loaf',
      'price': 38000,
      'priceText': 'Rp 38.000',
      'desc':
          'Roti artisan sourdough klasik berkulit renyah garing dengan bagian dalam yang empuk.',
      'image': 'assets/images/food_sourdough.jpg',
      'category': 'Food',
    },
    {
      'name': 'Butter Croissant',
      'price': 25000,
      'priceText': 'Rp 25.000',
      'desc':
          'Pastry croissant khas Prancis yang renyah berlayer dengan aroma mentega gurih.',
      'image': 'assets/images/food_croissant.jpg',
      'category': 'Food',
    },
    {
      'name': 'Berry Tart',
      'price': 35000,
      'priceText': 'Rp 35.000',
      'desc':
          'Kue tart manis dengan topping buah beri segar dan krim custard lembut.',
      'image': 'assets/images/food_tart.jpg',
      'category': 'Food',
    },
    {
      'name': 'Avocado Toast',
      'price': 45000,
      'priceText': 'Rp 45.000',
      'desc':
          'Roti panggang dengan olesan alpukat segar, irisan buah, dan taburan bumbu halus.',
      'image': 'assets/images/food_avocado.jpg',
      'category': 'Food',
    },
    {
      'name': 'Nasi Goreng Special',
      'price': 35000,
      'priceText': 'Rp 35.000',
      'desc':
          'Nasi goreng rempah khas cafe disajikan dengan telur ceplok, sate ayam, dan kerupuk.',
      'image': 'assets/images/food_nasigoreng.jpg',
      'category': 'Food',
    },
    {
      'name': 'Spaghetti Carbonara',
      'price': 42000,
      'priceText': 'Rp 42.000',
      'desc':
          'Pasta spaghetti al dente dengan saus keju creamy, smoked beef, dan taburan keju parmesan.',
      'image': 'assets/images/food_carbonara.jpg',
      'category': 'Food',
    },
    {
      'name': 'Chicken Club Sandwich',
      'price': 38000,
      'priceText': 'Rp 38.000',
      'desc':
          'Sandwich lapis tiga isi daging ayam panggang, keju cheddar, telur, dan kentang goreng.',
      'image': 'assets/images/food_sandwich.jpg',
      'category': 'Food',
    },
    {
      'name': 'Beef Burger Deluxe',
      'price': 48000,
      'priceText': 'Rp 48.000',
      'desc':
          'Burger patty sapi juicy dengan keju leleh, caramelized onion, dan saus BBQ spesial.',
      'image': 'assets/images/food_burger.jpg',
      'category': 'Food',
    },
  ];

  final List<Map<String, dynamic>> _drinkItems = [
    {
      'name': 'Ice Latte',
      'price': 28000,
      'priceText': 'Rp 28.000',
      'desc':
          'Es kopi latte segar dengan perpaduan espresso kaya rasa dan susu UHT dingin yang creamy.',
      'image': 'assets/images/ice latte.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Americano',
      'price': 24000,
      'priceText': 'Rp 24.000',
      'desc':
          'Sajian es kopi hitam espresso murni dingin yang segar dan mantap.',
      'image': 'assets/images/drink_latte.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Signature Chocolate',
      'price': 35000,
      'priceText': 'Rp 35.000',
      'desc':
          'Minuman es cokelat pekat premium dengan racikan susu segar manis lezat.',
      'image': 'assets/images/Ice Chocolate.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Tuffenut Latte',
      'price': 32000,
      'priceText': 'Rp 32.000',
      'desc':
          'Es latte aroma toffee nut manis gurih dengan topping foam susu yang lembut.',
      'image': 'assets/images/drink_latte.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Thai Tea',
      'price': 22000,
      'priceText': 'Rp 22.000',
      'desc': 'Teh segar disajikan dingin manis creamy khas sajian thai tea.',
      'image': 'assets/images/drink_lemontea.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Caramel Machiato',
      'price': 32000,
      'priceText': 'Rp 32.000',
      'desc':
          'Kopi susu dingin dengan syrup vanilla, foam lembut, dan siraman saus karamel manis di atasnya.',
      'image': 'assets/images/Ice Caramel Machiato.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Tea',
      'price': 15000,
      'priceText': 'Rp 15.000',
      'desc':
          'Es teh manis dingin segar perasan lemon pilihan untuk penyegar dahaga.',
      'image': 'assets/images/drink_lemontea.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Creamy Machiato',
      'price': 30000,
      'priceText': 'Rp 30.000',
      'desc':
          'Kopi macchiato dingin ekstra creamy dengan lapisan espresso dan susu lezat.',
      'image': 'assets/images/drink_latte.jpg',
      'category': 'Drink',
    },
    {
      'name': 'Ice Matcha',
      'price': 30000,
      'priceText': 'Rp 30.000',
      'desc':
          'Seduhan teh hijau matcha jepang asli warna hijau segar dipadukan susu creamy dingin.',
      'image': 'assets/images/drink_matcha.jpg',
      'category': 'Drink',
    },
  ];

  final List<Map<String, dynamic>> _snackItems = [
    {
      'name': 'Choco Chip Cookie',
      'price': 18000,
      'priceText': 'Rp 18.000',
      'desc':
          'Kue kering cokelat choco chip panggang renyah manis dengan potongan cokelat belgia.',
      'image': 'assets/images/snack_cookie.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Almond Muffin',
      'price': 22000,
      'priceText': 'Rp 22.000',
      'desc':
          'Muffin lembut hangat berbahan keju/almond dengan topping taburan kacang renyah.',
      'image': 'assets/images/snack_muffin.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Pisang Goreng',
      'price': 15000,
      'priceText': 'Rp 15.000',
      'desc':
          'Camilan pisang goreng crispy warna keemasan hangat renyah di luar, manis lembut di dalam.',
      'image': 'assets/images/snack_pisanggoreng.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Kentang Goreng',
      'price': 18000,
      'priceText': 'Rp 18.000',
      'desc':
          'Kentang goreng french fries potongan memanjang renyah gurih hangat disajikan dengan saus cocolan.',
      'image': 'assets/images/snack_kentang.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Jamur Goreng',
      'price': 16000,
      'priceText': 'Rp 16.000',
      'desc':
          'Jamur tiram/kancing crispy goreng tepung roti bumbu gurih yang renyah dan nagih.',
      'image': 'assets/images/snack_jamur.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Kebab',
      'price': 22000,
      'priceText': 'Rp 22.000',
      'desc':
          'Kebab gulung tortilla isi olahan daging sapi cincang, sayuran segar, dan saus spesial.',
      'image': 'assets/images/snack_kebab.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Bakwan Goreng Udang',
      'price': 15000,
      'priceText': 'Rp 15.000',
      'desc':
          'Gorengan bakwan sayur gurih renyah dengan topping udang utuh segar dan rempah.',
      'image': 'assets/images/snack_bakwan.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Cimol Keju',
      'price': 14000,
      'priceText': 'Rp 14.000',
      'desc':
          'Bola-bola cimol tapioka kenyal renyah dengan isian keju lumer dan taburan bumbu pedas gurih.',
      'image': 'assets/images/snack_cimol.png',
      'category': 'Snack',
    },
    {
      'name': 'Donat Kentang',
      'price': 12000,
      'priceText': 'Rp 12.000',
      'desc':
          'Donat kentang empuk berbentuk cincin manis lezat dengan taburan gula halus putih.',
      'image': 'assets/images/snack_donatkentang.jpg',
      'category': 'Snack',
    },
    {
      'name': 'Tahu Cabe Garam',
      'price': 16000,
      'priceText': 'Rp 16.000',
      'desc':
          'Potongan tahu crispy goreng bumbu pedas gurih taburan cabai rawit dan bawang garam melimpah.',
      'image': 'assets/images/snack_tahucabegaram.jpg',
      'category': 'Snack',
    },
  ];

  final List<Map<String, dynamic>> _dessertItems = [
    {
      'name': 'Berry Cheesecake',
      'price': 28000,
      'priceText': 'Rp 28.000',
      'desc':
          'Kue keju cheesecake lembut ala New York disiram selai compote buah beri manis segar.',
      'image': 'assets/images/dessert_cheesecake.jpg',
      'category': 'Dessert',
    },
    {
      'name': 'Tiramisu Cup',
      'price': 30000,
      'priceText': 'Rp 30.000',
      'desc':
          'Dessert tiramisu khas Italia dalam cup dengan biskuit ladyfinger siram espresso dan keju mascarpone.',
      'image': 'assets/images/dessert_tiramisu.jpg',
      'category': 'Dessert',
    },
  ];

  late final Map<String, List<Map<String, dynamic>>> categoryDataMap = {
    'Food': _foodItems,
    'Drink': _drinkItems,
    'Snack': _snackItems,
    'Dessert': _dessertItems,
  };

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && !categories.contains(trimmed)) {
      categories.add(trimmed);
      categoryDataMap[trimmed] = [];
    }
  }

  void renameCategory(String oldName, String newName) {
    final oldTrimmed = oldName.trim();
    final newTrimmed = newName.trim();
    if (newTrimmed.isNotEmpty && oldTrimmed != newTrimmed) {
      final index = categories.indexOf(oldTrimmed);
      if (index != -1) {
        categories[index] = newTrimmed;
      }
      final items = categoryDataMap.remove(oldTrimmed) ?? [];
      for (final it in items) {
        it['category'] = newTrimmed;
      }
      categoryDataMap[newTrimmed] = items;
    }
  }

  void deleteCategory(String name) {
    categories.remove(name);
    categoryDataMap.remove(name);
  }

  void addMenuItem(String categoryName, Map<String, dynamic> item) {
    if (!categoryDataMap.containsKey(categoryName)) {
      categoryDataMap[categoryName] = [];
      if (!categories.contains(categoryName)) {
        categories.add(categoryName);
      }
    }
    categoryDataMap[categoryName]!.add(item);
  }
}
