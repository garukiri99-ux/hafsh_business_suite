import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      child: ListTile(
        onTap: onTap,

        title: Text(
          transaction.invoice.number,
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(transaction.paymentMethod.name),

            Text(
              DateFormat(
                'dd MMM yyyy HH:mm',
              ).format(
                transaction.invoice.createdAt,
              ),
            ),
          ],
        ),

        trailing: Text(
          currency.format(transaction.total),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}