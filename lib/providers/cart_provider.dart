import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  String? _canteenId;
  String? _canteenName;

  List<CartItemModel> get items => List.unmodifiable(_items);
  String? get canteenId => _canteenId;
 
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0.0, (s, i) => s + i.subtotal);
  double get deliveryFee => 0.0;
  double get total => subtotal + deliveryFee;
  bool get isEmpty => _items.isEmpty;

  int quantityOf(String id) {
    final m = _items
        .cast<CartItemModel?>()
        .firstWhere((i) => i!.foodItem.id == id, orElse: () => null);
    return m?.quantity ?? 0;
  }

  bool canAddFromCanteen(String canteenId) {
    if (_items.isEmpty) return true;
    return _canteenId == canteenId;
  }

  void add(FoodItemModel food, {String? canteenName}) {
    if (_items.isEmpty) {
      _canteenId = food.canteenId;
      _canteenName = canteenName ?? food.canteenId;
    }
    final idx = _items.indexWhere((i) => i.foodItem.id == food.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
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
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity - 1);
    }
    if (_items.isEmpty) {
      _canteenId = null;
      _canteenName = null;
    }
    notifyListeners();
  }

  void removeAll(FoodItemModel food) {
    _items.removeWhere((i) => i.foodItem.id == food.id);
    if (_items.isEmpty) {
      _canteenId = null;
      _canteenName = null;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _canteenId = null;
    _canteenName = null;
    notifyListeners();
  }
}
