import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';

class CartBadge extends ConsumerWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    final totalItem = cart.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final totalPrice = cart.fold<int>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Checkout nanti
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.brown.shade100,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.brown,
                ),
                if (totalItem > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$totalItem",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            if (totalItem > 0) ...[
              const SizedBox(width: 10),
              Text(
                CurrencyFormatter.format(totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}