import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../providers/purchase_repository_provider.dart';

final purchaseOrderControllerProvider =
    AsyncNotifierProvider<
        PurchaseOrderController,
        List<PurchaseOrder>>(
  PurchaseOrderController.new,
);

class PurchaseOrderController
    extends AsyncNotifier<List<PurchaseOrder>> {
  PurchaseRepository get _repository =>
      ref.read(purchaseRepositoryProvider);

  @override
  Future<List<PurchaseOrder>> build() async {
    return _repository.getPurchaseOrders();
  }

  Future<void> addPurchaseOrder(
    PurchaseOrder purchaseOrder,
  ) async {
    await _repository.addPurchaseOrder(
      purchaseOrder,
    );

    state = AsyncData(
      await _repository.getPurchaseOrders(),
    );
  }

  Future<void> updatePurchaseOrder(
    PurchaseOrder purchaseOrder,
  ) async {
    await _repository.updatePurchaseOrder(
      purchaseOrder,
    );

    state = AsyncData(
      await _repository.getPurchaseOrders(),
    );
  }

  Future<void> deletePurchaseOrder(
    String id,
  ) async {
    await _repository.deletePurchaseOrder(id);

    state = AsyncData(
      await _repository.getPurchaseOrders(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = AsyncData(
      await _repository.getPurchaseOrders(),
    );
  }
}