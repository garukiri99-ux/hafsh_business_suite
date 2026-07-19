import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction.dart';
import '../../providers/transaction_repository_provider.dart';

final transactionHistoryControllerProvider =
    AsyncNotifierProvider<
        TransactionHistoryController,
        List<Transaction>>(
  TransactionHistoryController.new,
);

class TransactionHistoryController
    extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final repository =
        ref.read(transactionRepositoryProvider);

    return repository.getTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = AsyncData(
      await build(),
    );
  }
}