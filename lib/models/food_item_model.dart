import 'package:equatable/equatable.dart';

class FoodItemModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String categoryId;
  final String canteenId;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPopular;
  final List<String> tags;
  final int prepTimeMinutes;

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    required this.canteenId,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.isFeatured = false,
    this.isPopular  = false,
    this.tags       = const [],
    this.prepTimeMinutes = 10,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) => FoodItemModel(
        id:              json['id'] as String,
        name:            json['name'] as String,
        description:     json['description'] as String,
        price:           (json['price'] as num).toDouble(),
        imageUrl:        json['image_url'] as String?,
        categoryId:      json['category_id'] as String,
        canteenId:       json['canteen_id'] as String,
        rating:          (json['rating'] as num).toDouble(),
        reviewCount:     json['review_count'] as int,
        isAvailable:     json['is_available'] as bool,
        isFeatured:      json['is_featured'] as bool? ?? false,
        isPopular:       json['is_popular'] as bool? ?? false,
        tags:            List<String>.from(json['tags'] as List? ?? []),
        prepTimeMinutes: json['prep_time_minutes'] as int? ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'id':               id,
        'name':             name,
        'description':      description,
        'price':            price,
        'image_url':        imageUrl,
        'category_id':      categoryId,
        'canteen_id':       canteenId,
        'rating':           rating,
        'review_count':     reviewCount,
        'is_available':     isAvailable,
        'is_featured':      isFeatured,
        'is_popular':       isPopular,
        'tags':             tags,
        'prep_time_minutes':prepTimeMinutes,
      };

  String get prepTimeLabel => '$prepTimeMinutes min';
  String get ratingLabel   => rating.toStringAsFixed(1);

  @override
  List<Object?> get props => [id, name, price, categoryId, isAvailable];
}
