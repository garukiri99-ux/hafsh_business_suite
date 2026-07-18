import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';

class ChangeSummary extends StatelessWidget {
  final int change;

  const ChangeSummary({
    super.key,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text("Kembalian"),
        trailing: Text(
          CurrencyFormatter.format(change),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}