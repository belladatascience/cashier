import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final int? id;
  final String? docId;
  final String name;
  final int sortOrder;

  CategoryModel({
    this.id,
    this.docId,
    required this.name,
    this.sortOrder = 0,
  });

  /// Factory from Firebase Firestore DocumentSnapshot
  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return CategoryModel(docId: snapshot.id, name: '');
    }
    return CategoryModel.fromMap(data, docId: snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory CategoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return CategoryModel(docId: doc.id, name: '');
    }
    return CategoryModel.fromMap(data, docId: doc.id);
  }

  /// Factory from Map with Firestore-safe parsing
  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CategoryModel(
      id: map['id'] is num ? (map['id'] as num).toInt() : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      name: (map['name'] as String?) ?? '',
      sortOrder: map['sort_order'] is num
          ? (map['sort_order'] as num).toInt()
          : (map['sortOrder'] is num
              ? (map['sortOrder'] as num).toInt()
              : int.tryParse(map['sort_order']?.toString() ?? '0') ?? 0),
    );
  }

  /// Convert to Map for Firestore or Local Storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      'name': name,
      'sort_order': sortOrder,
    };
  }

  /// Convert to Firestore Map payload
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'sort_order': sortOrder,
    };
  }

  /// CopyWith helper for state updates
  CategoryModel copyWith({
    int? id,
    String? docId,
    String? name,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CategoryModel(id: $id, docId: $docId, name: $name, sortOrder: $sortOrder)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.docId == docId &&
        other.name == name &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(id, docId, name, sortOrder);
}
