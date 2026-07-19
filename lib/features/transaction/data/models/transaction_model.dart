import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';

class TransactionModel {
  final Transaction transaction;

  const TransactionModel(this.transaction);

  Map<String, dynamic> toMap() {
    return {
      'invoice': transaction.invoice.number,
      'createdAt':
          transaction.invoice.createdAt.toIso8601String(),

      'paymentMethod':
          transaction.paymentMethod.name,

      'subtotal': transaction.subtotal,
      'discount': transaction.discount,
      'tax': transaction.tax,
      'total': transaction.total,

      'paidAmount': transaction.paidAmount,
      'changeAmount': transaction.changeAmount,

      'items': transaction.items
          .map(_itemToMap)
          .toList(),
    };
  }

  static Map<String, dynamic> _itemToMap(
      TransactionItem item) {
    return {
      'productId': item.productId,
      'productName': item.productName,
      'price': item.price,
      'quantity': item.quantity,
      'subtotal': item.subtotal,
    };
  }
}