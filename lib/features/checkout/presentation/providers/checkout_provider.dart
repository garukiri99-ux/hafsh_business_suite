import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/providers/cart_provider.dart';

class CheckoutSummary {
  final int totalItem;
  final int subtotal;
  final int discount;
  final int tax;
  final int total;

  const CheckoutSummary({
    required this.totalItem,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });
}

final checkoutProvider = Provider<CheckoutSummary>((ref) {
  final cart = ref.watch(cartProvider);

  final totalItem = cart.fold<int>(
    0,
    (sum, item) => sum + item.quantity,
  );

  final subtotal = cart.fold<int>(
    0,
    (sum, item) => sum + item.subtotal,
  );

  const discount = 0;
  const tax = 0;

  return CheckoutSummary(
    totalItem: totalItem,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    total: subtotal - discount + tax,
  );
});