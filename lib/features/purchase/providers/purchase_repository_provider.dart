import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/purchase_repository.dart';
import '../domain/repositories/purchase_repository_impl.dart';

final purchaseRepositoryProvider =
    Provider<PurchaseRepository>((ref) {
  return PurchaseRepositoryImpl();
});