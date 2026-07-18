import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../pos/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/checkout_button.dart';
import '../widgets/checkout_item_card.dart';
import '../widgets/empty_checkout.dart';
import '../widgets/order_summary.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final summary = ref.watch(checkoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
      ),
      body: cart.isEmpty
          ? const EmptyCheckout()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      return CheckoutItemCard(
                        item: item,
                        onIncrease: () {
                          ref
                              .read(cartProvider.notifier)
                              .increase(item.product);
                        },
                        onDecrease: () {
                          ref
                              .read(cartProvider.notifier)
                              .decrease(item.product);
                        },
                        onDelete: () {
                          ref
                              .read(cartProvider.notifier)
                              .remove(item.product);
                        },
                      );
                    },
                  ),
                ),
                OrderSummary(
                  totalItem: summary.totalItem,
                  subtotal: summary.total,
                ),
                CheckoutButton(
                  onPressed: () {
                    context.push('/payment');
                  },
                ),
              ],
            ),
    );
  }
}