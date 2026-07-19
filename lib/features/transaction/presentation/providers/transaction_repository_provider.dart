import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    db: FirebaseFirestore.instance,
  );
});