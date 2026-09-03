import 'dart:typed_data';

class MenuItemModel {
  final int? id;
  final String name;
  final int price;
  final String priceText;
  final String desc;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String category;
  final int isActive;

  MenuItemModel({
    this.id,
    required this.name,
    required this.price,
    required this.priceText,
    required this.desc,
    this.imagePath,
    this.imageBytes,
    required this.category,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'price_text': priceText,
      'desc': desc,
      'image_path': imagePath,
      'image_bytes': imageBytes,
      'category': category,
      'is_active': isActive,
    };
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toInt(),
      priceText: map['price_text'] ?? 'Rp ${map['price']}',
      desc: map['desc'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      imageBytes: map['image_bytes'] as Uint8List?,
      category: map['category'] as String,
      isActive: (map['is_active'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'priceText': priceText,
      'desc': desc,
      'image': imageBytes ?? imagePath ?? 'assets/images/food_sourdough.jpg',
      'imagePath': imagePath,
      'imageBytes': imageBytes,
      'category': category,
    };
  }
}
