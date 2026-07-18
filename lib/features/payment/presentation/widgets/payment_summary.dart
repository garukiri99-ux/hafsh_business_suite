import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';

class PaymentSummary extends StatelessWidget {
  final int total;

  const PaymentSummary({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 20,
        ),
        child: Column(
          children: [
            const Text(
              "TOTAL PEMBAYARAN",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}