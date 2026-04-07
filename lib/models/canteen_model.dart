import 'package:equatable/equatable.dart';

class CanteenModel extends Equatable {
  final String id;
  final String name;
  final String location;
  final String? imageUrl;
  final String? description;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  const CanteenModel({
    required this.id,
    required this.name,
    required this.location,
    this.imageUrl,
    this.description,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  factory CanteenModel.fromJson(Map<String, dynamic> json) => CanteenModel(
        id:          json['id'] as String,
        name:        json['name'] as String,
        location:    json['location'] as String,
        imageUrl:    json['image_url'] as String?,
        description: json['description'] as String?,
        rating:      (json['rating'] as num).toDouble(),
        reviewCount: json['review_count'] as int,
        isOpen:      json['is_open'] as bool,
        openTime:    json['open_time'] as String,
        closeTime:   json['close_time'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'name':         name,
        'location':     location,
        'image_url':    imageUrl,
        'description':  description,
        'rating':       rating,
        'review_count': reviewCount,
        'is_open':      isOpen,
        'open_time':    openTime,
        'close_time':   closeTime,
      };

  String get statusLabel => isOpen ? 'Open Now' : 'Closed';
  String get hours => '$openTime – $closeTime';

  @override
  List<Object?> get props =>
      [id, name, location, rating, reviewCount, isOpen];
}
