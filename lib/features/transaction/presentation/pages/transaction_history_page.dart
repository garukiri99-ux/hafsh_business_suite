import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_history_controller.dart';
import '../widgets/transaction_card.dart';

class TransactionHistoryPage extends ConsumerWidget {
  const TransactionHistoryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(
      transactionHistoryControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
                transactionHistoryControllerProvider.notifier,
              )
              .refresh();
        },
        child: history.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada transaksi',
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (_, index) {
                return TransactionCard(
                  transaction: transactions[index],
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Center(
            child: Text(e.toString()),
          ),
        ),
      ),
    );
  }
}