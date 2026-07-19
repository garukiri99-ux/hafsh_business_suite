import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransactionStatus {
  idle,
  loading,
  success,
  error,
}

class TransactionController extends Notifier<TransactionStatus> {
  @override
  TransactionStatus build() {
    return TransactionStatus.idle;
  }

  Future<void> execute(
    Future<void> Function() action,
  ) async {
    state = TransactionStatus.loading;

    try {
      await action();
      state = TransactionStatus.success;
    } catch (e) {
      state = TransactionStatus.error;
      rethrow;
    }
  }

  void reset() {
    state = TransactionStatus.idle;
  }
}

final transactionControllerProvider =
    NotifierProvider<TransactionController, TransactionStatus>(
  TransactionController.new,
);