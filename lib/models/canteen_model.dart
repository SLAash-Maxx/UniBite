import 'package:equatable/equatable.dart';

enum CrowdLevel { low, medium, high }

extension CrowdLevelX on CrowdLevel {
  String get label {
    switch (this) {
      case CrowdLevel.low:    return 'Low';
      case CrowdLevel.medium: return 'Medium';
      case CrowdLevel.high:   return 'High';
    }
  }

  String get emoji {
    switch (this) {
      case CrowdLevel.low:    return '🟢';
      case CrowdLevel.medium: return '🟡';
      case CrowdLevel.high:   return '🔴';
    }
  }
}

class CanteenModel extends Equatable {
  final String id;
  final String name;
  final String location;
  final String? imageUrl;
  final String? description;
  final double  rating;
  final int     reviewCount;
  final bool    isOpen;
  final String  openTime;
  final String  closeTime;
  final CrowdLevel crowdLevel;         // NEW
  final DateTime?  crowdUpdatedAt;     // NEW

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
    this.crowdLevel     = CrowdLevel.low,
    this.crowdUpdatedAt,
  });

  factory CanteenModel.fromJson(Map<String, dynamic> json) {
    CrowdLevel crowd = CrowdLevel.low;
    final raw = json['crowd_level']?.toString();
    if (raw == 'medium') crowd = CrowdLevel.medium;
    if (raw == 'high')   crowd = CrowdLevel.high;

    // Safe parsing helpers
    double safeDouble(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    int safeInt(dynamic val, int fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    bool safeBool(dynamic val, bool fallback) {
      if (val == null) return fallback;
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      return fallback;
    }

    return CanteenModel(
      id:             (json['id'] ?? '') as String,
      name:           (json['name'] ?? 'Unknown Canteen') as String,
      location:       (json['location'] ?? 'Location N/A') as String,
      imageUrl:       json['image_url'] as String?,
      description:    json['description'] as String?,
      rating:         safeDouble(json['rating'], 0.0),
      reviewCount:    safeInt(json['review_count'], 0),
      isOpen:         safeBool(json['is_open'], false),
      openTime:       (json['open_time'] ?? '8:00 AM') as String,
      closeTime:      (json['close_time'] ?? '5:00 PM') as String,
      crowdLevel:     crowd,
      crowdUpdatedAt: json['crowd_updated_at'] != null
          ? DateTime.tryParse(json['crowd_updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':               id,
        'name':             name,
        'location':         location,
        'image_url':        imageUrl,
        'description':      description,
        'rating':           rating,
        'review_count':     reviewCount,
        'is_open':          isOpen,
        'open_time':        openTime,
        'close_time':       closeTime,
        'crowd_level':      crowdLevel.name,
        'crowd_updated_at': crowdUpdatedAt?.toIso8601String(),
      };

  String get statusLabel => isOpen ? 'Open Now' : 'Closed';
  String get hours => '$openTime – $closeTime';

  @override
  List<Object?> get props =>
      [id, name, location, rating, reviewCount, isOpen, crowdLevel];
}
