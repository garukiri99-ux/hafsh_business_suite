import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';

class OrderSummary extends StatelessWidget {
  final int totalItem;
  final int subtotal;

  const OrderSummary({
    super.key,
    required this.totalItem,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xffEEEEEE),
          ),
        ),
      ),
      child: Column(
        children: [

          _buildRow(
            "Jumlah Item",
            "$totalItem Item",
          ),

          const SizedBox(height: 10),

          _buildRow(
            "Subtotal",
            CurrencyFormatter.format(subtotal),
          ),

          const Divider(height: 28),

          _buildRow(
            "TOTAL",
            CurrencyFormatter.format(subtotal),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      children: [

        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? Colors.green
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}