import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final firestore.FirebaseFirestore db;

  const TransactionRepositoryImpl({
    required this.db,
  });

  @override
  Future<void> save(Transaction transaction) async {
    final model = TransactionModel(transaction);

    await db
        .collection('transactions')
        .doc(transaction.invoice.number)
        .set(model.toMap());
  }
}