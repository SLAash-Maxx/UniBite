import 'package:equatable/equatable.dart';
import 'food_item_model.dart';

class CartItemModel extends Equatable {
  final FoodItemModel foodItem;
  final int quantity;

  const CartItemModel({
    required this.foodItem,
    required this.quantity,
  });

  double get subtotal => foodItem.price * quantity;

  CartItemModel copyWith({FoodItemModel? foodItem, int? quantity}) =>
      CartItemModel(
        foodItem: foodItem ?? this.foodItem,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
        'food_item': foodItem.toJson(),
        'quantity':  quantity,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        foodItem: FoodItemModel.fromJson(
            json['food_item'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
      );

  @override
  List<Object?> get props => [foodItem.id, quantity];
}
