class CategoryModel {
  final int? id;
  final String name;
  final int sortOrder;

  CategoryModel({this.id, required this.name, this.sortOrder = 0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'sort_order': sortOrder};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }
}
