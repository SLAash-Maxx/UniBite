import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<List<OrderModel>> getOrders() async {
    try {
      final snap = await _db
          .collection('orders')
          .where('user_id', isEqualTo: _uid)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs
          .map((d) => OrderModel.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<OrderModel> placeOrder({
    required List<CartItemModel> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    String? note,
  }) async {
    final now  = DateTime.now();
    final data = {
      'user_id':      _uid,
      'canteen_id':   'main',
      'items':        items.map((i) => i.toJson()).toList(),
      'subtotal':     subtotal,
      'delivery_fee': deliveryFee,
      'total':        total,
      'status':       'placed',
      'created_at':   now.toIso8601String(),
      if (note != null) 'note': note,
    };

    final ref = await _db.collection('orders').add(data);

    return OrderModel.fromJson({'id': ref.id, ...data});
  }
}
