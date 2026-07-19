import '../../../checkout/presentation/providers/checkout_provider.dart';
import '../../../payment/domain/entities/payment_method.dart';
import '../../../pos/domain/entities/cart_item.dart';

import '../entities/transaction.dart';
import 'transaction_builder.dart';

class TransactionService {
  Transaction buildTransaction({
    required List<CartItem> cart,
    required CheckoutSummary summary,
    required PaymentMethod paymentMethod,
    required int paidAmount,
  }) {
    return TransactionBuilder.build(
      cart: cart,
      summary: summary,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount,
    );
  }
}