import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

enum OrderStatus { placed, preparing, ready, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive =>
      this == OrderStatus.placed || this == OrderStatus.preparing;
}

class OrderModel extends Equatable {
  final String id;
  final String userId;
  final String canteenId;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? note;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.canteenId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.note,
  });

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        canteenId: json['canteen_id'] as String,
        items: (json['items'] as List)
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        deliveryFee: (json['delivery_fee'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        status: OrderStatus.values.firstWhere((s) => s.name == json['status'],
            orElse: () => OrderStatus.placed),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'canteen_id': canteenId,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total': total,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'note': note,
      };

  @override
  List<Object?> get props => [id, status, total];
}
