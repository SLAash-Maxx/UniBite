import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletModel? _wallet;
  bool _isLoading = false;

  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  double get balance => _wallet?.balance ?? 0.0;

  Future<void> loadWallet() async {
    _isLoading = true;
    notifyListeners();
    _wallet = await _service.getWallet();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deduct({required double amount, required String orderId}) async {
    final ok = await _service.deduct(amount: amount, orderId: orderId);
    if (ok) await loadWallet();
    return ok;
  }

  Future<void> refund({required double amount, required String orderId}) async {
    await _service.refund(amount: amount, orderId: orderId);
    await loadWallet();
  }
}
