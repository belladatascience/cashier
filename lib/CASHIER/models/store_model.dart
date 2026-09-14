import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final int? id;
  final String? docId;
  final String name;
  final String location;
  final String defaultShift;

  StoreModel({
    this.id,
    this.docId,
    required this.name,
    required this.location,
    this.defaultShift = 'Pagi',
  });

  /// Factory from Firebase Firestore DocumentSnapshot
  factory StoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return StoreModel(
        docId: snapshot.id,
        name: '',
        location: '',
      );
    }
    return StoreModel.fromMap(data, docId: snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory StoreModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return StoreModel(
        docId: doc.id,
        name: '',
        location: '',
      );
    }
    return StoreModel.fromMap(data, docId: doc.id);
  }

  /// Factory from Map with Firestore-safe parsing
  factory StoreModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawId = map['id'];

    return StoreModel(
      id: rawId is num
          ? rawId.toInt()
          : (rawId != null ? int.tryParse(rawId.toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      name: (map['name'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      defaultShift: (map['default_shift'] as String?) ??
          (map['defaultShift'] as String?) ??
          'Pagi',
    );
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      'name': name,
      'location': location,
      'default_shift': defaultShift,
    };
  }

  /// Convert to Firestore payload Map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'location': location,
      'default_shift': defaultShift,
    };
  }

  /// CopyWith helper for state updates
  StoreModel copyWith({
    int? id,
    String? docId,
    String? name,
    String? location,
    String? defaultShift,
  }) {
    return StoreModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      location: location ?? this.location,
      defaultShift: defaultShift ?? this.defaultShift,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreModel.fromJson(String source) =>
      StoreModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StoreModel(id: $id, docId: $docId, name: $name, location: $location, defaultShift: $defaultShift)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreModel &&
        other.id == id &&
        other.docId == docId &&
        other.name == name &&
        other.location == location &&
        other.defaultShift == defaultShift;
  }

  @override
  int get hashCode {
    return Object.hash(id, docId, name, location, defaultShift);
  }
}
