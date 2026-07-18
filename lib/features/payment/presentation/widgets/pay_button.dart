import 'package:flutter/material.dart';

class PayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PayButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.payments),
          label: const Text("BAYAR SEKARANG"),
        ),
      ),
    );
  }
}