import 'package:flutter/material.dart';

class PaymentAmountField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentAmountField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Nominal Bayar",
          border: OutlineInputBorder(),
          prefixText: "Rp ",
        ),
      ),
    );
  }
}