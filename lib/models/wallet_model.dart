import 'package:equatable/equatable.dart';

enum TransactionType { topUp, orderPayment, orderRefund }

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.topUp:         return 'Top Up';
      case TransactionType.orderPayment:  return 'Order Payment';
      case TransactionType.orderRefund:   return 'Order Refund';
    }
  }
  bool get isCredit =>
      this == TransactionType.topUp || this == TransactionType.orderRefund;
}

class WalletTransaction extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String? orderId;
  final String? note;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.orderId,
    this.note,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id:        json['id'] as String,
        type:      TransactionType.values.firstWhere(
            (t) => t.name == json['type'],
            orElse: () => TransactionType.topUp),
        amount:    (json['amount'] as num).toDouble(),
        orderId:   json['order_id'] as String?,
        note:      json['note'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'type':       type.name,
        'amount':     amount,
        'order_id':   orderId,
        'note':       note,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, type, amount, createdAt];
}

class WalletModel extends Equatable {
  final String userId;
  final double balance;
  final List<WalletTransaction> transactions;

  const WalletModel({
    required this.userId,
    required this.balance,
    this.transactions = const [],
  });

  factory WalletModel.empty(String userId) =>
      WalletModel(userId: userId, balance: 0.0);

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        userId:       json['user_id'] as String,
        balance:      (json['balance'] as num).toDouble(),
        transactions: (json['transactions'] as List? ?? [])
            .map((e) => WalletTransaction.fromJson(
                {'id': e['id'] ?? '', ...e as Map<String, dynamic>}))
            .toList(),
      );

  @override
  List<Object?> get props => [userId, balance];
}
