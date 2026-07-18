import 'package:flutter/material.dart';

import '../../domain/entities/payment_method.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Metode Pembayaran",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<PaymentMethod>(
              segments: const [
                ButtonSegment(
                  value: PaymentMethod.cash,
                  icon: Icon(Icons.payments),
                  label: Text("Tunai"),
                ),
                ButtonSegment(
                  value: PaymentMethod.qris,
                  icon: Icon(Icons.qr_code),
                  label: Text("QRIS"),
                ),
                ButtonSegment(
                  value: PaymentMethod.transfer,
                  icon: Icon(Icons.account_balance),
                  label: Text("Transfer"),
                ),
              ],
              selected: {value},
              onSelectionChanged: (selection) {
                onChanged(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}