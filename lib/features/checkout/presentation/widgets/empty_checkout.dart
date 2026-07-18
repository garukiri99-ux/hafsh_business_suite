import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyCheckout extends StatelessWidget {
  const EmptyCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum ada pesanan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silakan tambahkan menu terlebih dahulu.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Kembali ke POS"),
            ),
          ],
        ),
      ),
    );
  }
}