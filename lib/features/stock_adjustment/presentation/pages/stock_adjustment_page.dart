import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stock_adjustment_provider.dart';

class StockAdjustmentPage extends ConsumerWidget {
  const StockAdjustmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustments = ref.watch(
      stockAdjustmentControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
      ),
      body: adjustments.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Terjadi kesalahan.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data stock adjustment.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      item.isStockIn ? '+' : '-',
                    ),
                  ),
                  title: Text(item.productName),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.type.name.toUpperCase()} • Qty ${item.quantity}',
                      ),
                      Text(item.reason.name),
                    ],
                  ),
                  trailing: Text(
                    item.stockAfter.toString(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Form Stock Adjustment akan dibuat pada langkah berikutnya.',
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}