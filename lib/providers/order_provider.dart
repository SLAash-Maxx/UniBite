import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service = OrderService();
  WalletProvider? wallet;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _error;
  StreamSubscription<List<OrderModel>>? _sub;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get error => _error;

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();

  OrderModel? findById(String id) => _orders
      .cast<OrderModel?>()
      .firstWhere((o) => o!.id == id, orElse: () => null);

  /// Start real-time listener — call once after login
  void startListening() {
    _sub?.cancel();
    _sub = _service.watchOrders().listen(
      (orders) {
        _orders = orders;
        _hasError = false;
        notifyListeners();
      },
      onError: (_) {
        _hasError = true;
        notifyListeners();
      },
    );
  }

  Future<void> loadOrders() async {
    startListening();
    _isLoading = true;
    _hasError = false;
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
    _error = null;
    notifyListeners();
    try {
      if (wallet != null && wallet!.balance < cart.total) {
        _error = 'Insufficient wallet balance. Please top up.';
        return false;
      }
      final order = await _service.placeOrder(
        items: cart.items,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        total: cart.total,
        canteenId: cart.canteenId ?? 'ps',
      );
      if (wallet != null) {
        await wallet!.deduct(amount: cart.total, orderId: order.id);
      }

      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _service.cancelOrder(orderId);
      if (ok) {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          final o = _orders[idx];
          if (wallet != null) {
            await wallet!.refund(amount: o.total, orderId: orderId);
          }
          _orders[idx] = o.copyWith(
              status: OrderStatus.cancelled, updatedAt: DateTime.now());
          notifyListeners();
        }
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
