import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MenuItemModel {
  final int? id;
  final String? docId;
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
    this.docId,
    required this.name,
    required this.price,
    required this.priceText,
    required this.desc,
    this.imagePath,
    this.imageBytes,
    required this.category,
    this.isActive = 1,
  });

  /// Factory from Firebase Firestore DocumentSnapshot
  factory MenuItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return MenuItemModel(
        docId: snapshot.id,
        name: '',
        price: 0,
        priceText: 'Rp 0',
        desc: '',
        category: '',
      );
    }
    return MenuItemModel.fromMap(data, docId: snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory MenuItemModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return MenuItemModel(
        docId: doc.id,
        name: '',
        price: 0,
        priceText: 'Rp 0',
        desc: '',
        category: '',
      );
    }
    return MenuItemModel.fromMap(data, docId: doc.id);
  }

  /// Helper to convert dynamic raw bytes to Uint8List
  static Uint8List? _parseBytes(dynamic value) {
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

  /// Helper to convert bytes to base64 string
  static String? _bytesToBase64(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    return base64Encode(bytes);
  }

  /// Factory from Map with Firestore-safe parsing
  factory MenuItemModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawPrice = map['price'];
    final priceVal = rawPrice is num
        ? rawPrice.toInt()
        : (int.tryParse(rawPrice?.toString() ?? '0') ?? 0);

    return MenuItemModel(
      id: map['id'] is num
          ? (map['id'] as num).toInt()
          : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      name: (map['name'] as String?) ?? '',
      price: priceVal,
      priceText: map['price_text'] as String? ??
          map['priceText'] as String? ??
          'Rp $priceVal',
      desc: (map['desc'] as String?) ?? '',
      imagePath: map['image_path'] as String? ?? map['imagePath'] as String?,
      imageBytes: _parseBytes(map['image_bytes'] ?? map['imageBytes']),
      category: (map['category'] as String?) ?? '',
      isActive: map['is_active'] is num
          ? (map['is_active'] as num).toInt()
          : (map['isActive'] is num
              ? (map['isActive'] as num).toInt()
              : int.tryParse(map['is_active']?.toString() ?? '1') ?? 1),
    );
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
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

  /// Convert to Firestore-compatible Map (stores bytes as Base64 String)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'price': price,
      'price_text': priceText,
      'desc': desc,
      'image_path': imagePath,
      if (imageBytes != null) 'image_bytes': _bytesToBase64(imageBytes),
      'category': category,
      'is_active': isActive,
    };
  }

  /// Legacy Map for legacy views
  Map<String, dynamic> toLegacyMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
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

  /// CopyWith helper for state updates
  MenuItemModel copyWith({
    int? id,
    String? docId,
    String? name,
    int? price,
    String? priceText,
    String? desc,
    String? imagePath,
    Uint8List? imageBytes,
    String? category,
    int? isActive,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      price: price ?? this.price,
      priceText: priceText ?? this.priceText,
      desc: desc ?? this.desc,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  String toJson() => json.encode(toMap());

  factory MenuItemModel.fromJson(String source) =>
      MenuItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MenuItemModel(id: $id, docId: $docId, name: $name, price: $price, category: $category, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemModel &&
        other.id == id &&
        other.docId == docId &&
        other.name == name &&
        other.price == price &&
        other.category == category &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, docId, name, price, category, isActive);
  }
}
