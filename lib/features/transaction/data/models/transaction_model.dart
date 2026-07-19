import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';

class TransactionModel {
  final Transaction transaction;

  const TransactionModel(this.transaction);

  Map<String, dynamic> toMap() {
    return {
      'invoice': transaction.invoice.number,

      'createdAt': firestore.Timestamp.fromDate(
        transaction.invoice.createdAt,
      ),

      'status': transaction.status,

      'cashierId': transaction.cashierId,

      'cashierName': transaction.cashierName,

      'paymentMethod': transaction.paymentMethod.name,

      'subtotal': transaction.subtotal,
      'discount': transaction.discount,
      'tax': transaction.tax,
      'total': transaction.total,

      'paidAmount': transaction.paidAmount,
      'changeAmount': transaction.changeAmount,

      'note': transaction.note,

      'items': transaction.items
          .map(_itemToMap)
          .toList(),
    };
  }

  static Map<String, dynamic> _itemToMap(
    TransactionItem item,
  ) {
    return {
      'productId': item.productId,
      'productName': item.productName,
      'price': item.price,
      'quantity': item.quantity,
      'subtotal': item.subtotal,
    };
  }
}