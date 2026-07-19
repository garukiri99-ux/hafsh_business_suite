import '../../../payment/domain/entities/payment_method.dart';

import 'invoice.dart';
import 'transaction_item.dart';

class Transaction {
  final Invoice invoice;

  final List<TransactionItem> items;

  final PaymentMethod paymentMethod;

  final int subtotal;
  final int discount;
  final int tax;
  final int total;

  final int paidAmount;
  final int changeAmount;

  /// Metadata
  final String status;

  final String cashierId;

  final String cashierName;

  final String? note;

  const Transaction({
    required this.invoice,
    required this.items,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    this.status = 'paid',
    this.cashierId = '',
    this.cashierName = '',
    this.note,
  });
}