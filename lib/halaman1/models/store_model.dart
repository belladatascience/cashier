class StoreModel {
  final int? id;
  final String name;
  final String location;
  final String defaultShift;

  StoreModel({
    this.id,
    required this.name,
    required this.location,
    this.defaultShift = 'Pagi',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'default_shift': defaultShift,
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      defaultShift: map['default_shift'] as String? ?? 'Pagi',
    );
  }
}
