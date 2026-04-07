import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final int itemCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.itemCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id:        json['id'] as String,
        name:      json['name'] as String,
        iconUrl:   json['icon_url'] as String?,
        itemCount: json['item_count'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'name':       name,
        'icon_url':   iconUrl,
        'item_count': itemCount,
      };

  /// Built-in categories seeded locally for the UI
  static List<CategoryModel> get defaults => [
        const CategoryModel(id: '0',  name: 'All',      itemCount: 0),
        const CategoryModel(id: '1',  name: 'Rice',     itemCount: 0),
        const CategoryModel(id: '2',  name: 'Noodles',  itemCount: 0),
        const CategoryModel(id: '3',  name: 'Snacks',   itemCount: 0),
        const CategoryModel(id: '4',  name: 'Drinks',   itemCount: 0),
        const CategoryModel(id: '5',  name: 'Desserts', itemCount: 0),
      ];

  @override
  List<Object?> get props => [id, name, itemCount];
}
