import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentAmountField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentAmountField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          RupiahInputFormatter(),
        ],
        decoration: const InputDecoration(
          labelText: "Nominal Bayar",
          prefixText: "Rp ",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number =
        int.tryParse(newValue.text.replaceAll('.', '')) ?? 0;

    final text = _format(number);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }

  String _format(int value) {
    final s = value.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < s.length; i++) {
      final position = s.length - i;

      buffer.write(s[i]);

      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}