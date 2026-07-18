import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<void> save(
    Transaction transaction,
  );
}