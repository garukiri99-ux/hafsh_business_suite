import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/providers/product_provider.dart';
import '../../../transaction/presentation/providers/transaction_history_controller.dart';
import 'stat_card.dart';

class QuickStats extends ConsumerWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productControllerProvider);
    final transactionsAsync =
        ref.watch(transactionHistoryControllerProvider);

    final today = DateTime.now();

    final productCount = productsAsync.when(
      data: (products) => products
          .where((product) => product.isActive)
          .length
          .toString(),
      loading: () => '…',
      error: (error, stackTrace) => '—',
    );

    final lowStockCount = productsAsync.when(
      data: (products) => products
          .where(
            (product) =>
                product.isActive &&
                product.stock <= product.minimumStock,
          )
          .length
          .toString(),
      loading: () => '…',
      error: (error, stackTrace) => '—',
    );

    final salesValue = transactionsAsync.when(
      data: (transactions) {
        final total = transactions
            .where(
              (transaction) =>
                  transaction.status.toLowerCase() == 'paid' &&
                  _isSameDay(transaction.invoice.createdAt, today),
            )
            .fold<int>(
              0,
              (sum, transaction) => sum + transaction.total,
            );

        return _formatRupiah(total);
      },
      loading: () => '…',
      error: (error, stackTrace) => '—',
    );

    final transactionCount = transactionsAsync.when(
      data: (transactions) => transactions
          .where(
            (transaction) =>
                transaction.status.toLowerCase() == 'paid' &&
                _isSameDay(transaction.invoice.createdAt, today),
          )
          .length
          .toString(),
      loading: () => '…',
      error: (error, stackTrace) => '—',
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
        children: [
          StatCard(
            icon: Icons.payments_rounded,
            title: 'Penjualan',
            value: salesValue,
            color: Colors.green,
            periodLabel: 'Hari ini',
          ),
          StatCard(
            icon: Icons.receipt_long_rounded,
            title: 'Transaksi',
            value: transactionCount,
            color: Colors.blue,
            periodLabel: 'Hari ini',
          ),
          StatCard(
            icon: Icons.inventory_2_rounded,
            title: 'Produk',
            value: productCount,
            color: Colors.orange,
            periodLabel: 'Produk aktif',
          ),
          StatCard(
            icon: Icons.warning_amber_rounded,
            title: 'Stok Menipis',
            value: lowStockCount,
            color: Colors.red,
            periodLabel: 'Perlu dicek',
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date, DateTime today) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(digits[i]);
    }

    return 'Rp ${buffer.toString()}';
  }
}