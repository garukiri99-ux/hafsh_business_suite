import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../../../payment/domain/entities/payment_method.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';

class TransactionModel {
  final Transaction transaction;

  const TransactionModel(this.transaction);

  // Tambahkan di sini 👇
  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawCreatedAt = map['createdAt'];

    final DateTime createdAt;

    if (rawCreatedAt is firestore.Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.parse(rawCreatedAt);
    } else {
      createdAt = DateTime.now();
    }

    return TransactionModel(
      Transaction(
        invoice: Invoice(
          number: map['invoice'] as String,
          createdAt: createdAt,
        ),
        items: (map['items'] as List)
            .map(
              (e) => TransactionItem(
                productId: e['productId'] as String,
                productName: e['productName'] as String,
                price: e['price'] as int,
                quantity: e['quantity'] as int,
              ),
            )
            .toList(),
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == map['paymentMethod'],
        ),
        subtotal: map['subtotal'] as int,
        discount: map['discount'] as int,
        tax: map['tax'] as int,
        total: map['total'] as int,
        paidAmount: map['paidAmount'] as int,
        changeAmount: map['changeAmount'] as int,
        status: map['status'] as String? ?? 'paid',
        cashierId: map['cashierId'] as String? ?? '',
        cashierName: map['cashierName'] as String? ?? '',
        note: map['note'] as String?,
      ),
    );
  }

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