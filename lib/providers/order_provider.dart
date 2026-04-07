import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service = OrderService();

  List<OrderModel> _orders    = [];
  bool             _isLoading = false;
  bool             _hasError  = false;

  List<OrderModel> get orders    => _orders;
  bool             get isLoading => _isLoading;
  bool             get hasError  => _hasError;

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();

  OrderModel? findById(String id) =>
      _orders.cast<OrderModel?>().firstWhere(
        (o) => o!.id == id,
        orElse: () => null,
      );

  Future<void> loadOrders() async {
    _isLoading = true;
    _hasError  = false;
    notifyListeners();
    try {
      _orders = await _service.getOrders();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder(CartProvider cart) async {
    _isLoading = true;
    notifyListeners();
    try {
      final order = await _service.placeOrder(
        items:       cart.items,
        subtotal:    cart.subtotal,
        deliveryFee: cart.deliveryFee,
        total:       cart.total,
      );
      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
