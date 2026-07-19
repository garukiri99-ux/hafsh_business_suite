import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/checkout_summary.dart';
import '../../../pos/presentation/providers/cart_provider.dart';

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