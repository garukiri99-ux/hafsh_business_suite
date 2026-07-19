import '../../../checkout/domain/entities/checkout_summary.dart';
import '../../../payment/domain/entities/payment_method.dart';
import '../../../pos/domain/entities/cart_item.dart';

import '../entities/invoice.dart';
import '../entities/transaction.dart';
import '../entities/transaction_item.dart';

class TransactionBuilder {
  static Transaction build({
    required List<CartItem> cart,
    required CheckoutSummary summary,
    required PaymentMethod paymentMethod,
    required int paidAmount,
  }) {
    final invoice = Invoice.generate();

    final items = cart.map((item) {
      return TransactionItem(
        productId: item.product.id,
        productName: item.product.name,
        price: item.product.price,
        quantity: item.quantity,
      );
    }).toList();

    return Transaction(
      invoice: invoice,
      items: items,
      paymentMethod: paymentMethod,
      subtotal: summary.subtotal,
      discount: summary.discount,
      tax: summary.tax,
      total: summary.total,
      paidAmount: paidAmount,
      changeAmount: paidAmount - summary.total,
    );
  }
}