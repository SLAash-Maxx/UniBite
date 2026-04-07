import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount =>
      _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.subtotal);

  double get deliveryFee => subtotal == 0 ? 0 : 0.0; // free pickup

  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  int quantityOf(String foodItemId) {
    final match = _items.cast<CartItemModel?>().firstWhere(
      (i) => i!.foodItem.id == foodItemId,
      orElse: () => null,
    );
    return match?.quantity ?? 0;
  }

  void add(FoodItemModel food) {
    final idx = _items.indexWhere((i) => i.foodItem.id == food.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
          quantity: _items[idx].quantity + 1);
    } else {
      _items.add(CartItemModel(foodItem: food, quantity: 1));
    }
    notifyListeners();
  }

  void remove(FoodItemModel food) {
    final idx = _items.indexWhere((i) => i.foodItem.id == food.id);
    if (idx < 0) return;
    if (_items[idx].quantity == 1) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(
          quantity: _items[idx].quantity - 1);
    }
    notifyListeners();
  }

  void removeAll(FoodItemModel food) {
    _items.removeWhere((i) => i.foodItem.id == food.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
