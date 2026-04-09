import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_model.dart';

class WalletService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<WalletModel> getWallet() async {
    try {
      final doc = await _db.collection('wallets').doc(_uid).get();
      if (!doc.exists) {
        await _db.collection('wallets').doc(_uid).set({
          'user_id': _uid,
          'balance': 0.0,
        });
        return WalletModel.empty(_uid);
      }
      final txSnap = await _db
          .collection('wallets')
          .doc(_uid)
          .collection('transactions')
          .orderBy('created_at', descending: true)
          .limit(30)
          .get();
      final txs = txSnap.docs
          .map((d) => WalletTransaction.fromJson({'id': d.id, ...d.data()}))
          .toList();
      return WalletModel(
        userId: doc['user_id'] as String,
        balance: (doc['balance'] as num).toDouble(),
        transactions: txs,
      );
    } catch (_) {
      return WalletModel.empty(_uid);
    }
  }

  Future<bool> deduct({
    required double amount,
    required String orderId,
  }) async {
    try {
      final ref = _db.collection('wallets').doc(_uid);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = (snap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
        if (current < amount) throw Exception('Insufficient balance');
        tx.update(ref, {'balance': current - amount});
        final txRef = ref.collection('transactions').doc();
        tx.set(txRef, {
          'id': txRef.id,
          'type': TransactionType.orderPayment.name,
          'amount': amount,
          'order_id': orderId,
          'note': 'Payment for order #${orderId.substring(0, 6)}',
          'created_at': DateTime.now().toIso8601String(),
        });
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refund({
    required double amount,
    required String orderId,
  }) async {
    try {
      final ref = _db.collection('wallets').doc(_uid);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = (snap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
        tx.update(ref, {'balance': current + amount});
        final txRef = ref.collection('transactions').doc();
        tx.set(txRef, {
          'id': txRef.id,
          'type': TransactionType.orderRefund.name,
          'amount': amount,
          'order_id': orderId,
          'note': 'Refund for cancelled order #${orderId.substring(0, 6)}',
          'created_at': DateTime.now().toIso8601String(),
        });
      });
    } catch (_) {}
  }
}
