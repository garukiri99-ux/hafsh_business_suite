import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/purchase_order_item.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../providers/purchase_repository_provider.dart';

final purchaseOrderItemControllerProvider =
    AsyncNotifierProvider<
        PurchaseOrderItemController,
        List<PurchaseOrderItem>>(
  PurchaseOrderItemController.new,
);

class PurchaseOrderItemController
    extends AsyncNotifier<List<PurchaseOrderItem>> {
  PurchaseRepository get _repository =>
      ref.read(purchaseRepositoryProvider);

  String? _purchaseOrderId;

  @override
  Future<List<PurchaseOrderItem>> build() async {
    return [];
  }

  Future<void> loadItems(
    String purchaseOrderId,
  ) async {
    _purchaseOrderId = purchaseOrderId;

    state = const AsyncLoading();

    state = AsyncData(
      await _repository.getPurchaseOrderItems(
        purchaseOrderId,
      ),
    );
  }

  Future<void> addItem(
    PurchaseOrderItem item,
  ) async {
    await _repository.addPurchaseOrderItem(item);

    await _reload();
  }

  Future<void> updateItem(
    PurchaseOrderItem item,
  ) async {
    await _repository.updatePurchaseOrderItem(item);

    await _reload();
  }

  Future<void> deleteItem(
    String id,
  ) async {
    await _repository.deletePurchaseOrderItem(id);

    await _reload();
  }

  Future<void> _reload() async {
    final purchaseOrderId = _purchaseOrderId;

    if (purchaseOrderId == null) {
      state = const AsyncData([]);
      return;
    }

    state = AsyncData(
      await _repository.getPurchaseOrderItems(
        purchaseOrderId,
      ),
    );
  }

  Future<void> refresh() async {
    await _reload();
  }
}