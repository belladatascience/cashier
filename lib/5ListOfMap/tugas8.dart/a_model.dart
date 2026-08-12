import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class BuahModel {
  final String nama;
  final String harga;
  final String asal;
  BuahModel({required this.nama, required this.harga, required this.asal});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'nama': nama, 'harga': harga, 'asal': asal};
  }

  factory BuahModel.fromMap(Map<String, dynamic> map) {
    return BuahModel(
      nama: map['nama'] as String,
      harga: map['harga'] as String,
      asal: map['asal'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BuahModel.fromJson(String source) =>
      BuahModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
