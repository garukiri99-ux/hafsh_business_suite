import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/providers/product_provider.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_order_item.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../providers/purchase_repository_provider.dart';

final purchaseOrderDetailControllerProvider =
    AsyncNotifierProvider<
        PurchaseOrderDetailController,
        PurchaseOrderDetailState>(
  PurchaseOrderDetailController.new,
);

class PurchaseOrderDetailState {
  const PurchaseOrderDetailState({
    required this.purchaseOrder,
    required this.items,
  });

  final PurchaseOrder purchaseOrder;
  final List<PurchaseOrderItem> items;

  double get itemSubtotal {
    return items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  double get totalQuantity {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get totalReceivedQuantity {
    return items.fold(
      0,
      (sum, item) => sum + item.receivedQuantity,
    );
  }

  double get totalRemainingQuantity {
    return items.fold(
      0,
      (sum, item) => sum + item.remainingQuantity,
    );
  }

  PurchaseOrderDetailState copyWith({
    PurchaseOrder? purchaseOrder,
    List<PurchaseOrderItem>? items,
  }) {
    return PurchaseOrderDetailState(
      purchaseOrder:
          purchaseOrder ?? this.purchaseOrder,
      items: items ?? this.items,
    );
  }
}

class PurchaseOrderDetailController
    extends AsyncNotifier<PurchaseOrderDetailState> {
  PurchaseRepository get _repository =>
      ref.read(purchaseRepositoryProvider);

  String? _purchaseOrderId;

  @override
  Future<PurchaseOrderDetailState> build() async {
    if (_purchaseOrderId == null) {
      throw StateError(
        'Purchase Order ID belum ditentukan.',
      );
    }

    return _load(_purchaseOrderId!);
  }

  Future<PurchaseOrderDetailState> _load(
    String purchaseOrderId,
  ) async {
    final purchaseOrder =
        await _repository.getPurchaseOrderById(
      purchaseOrderId,
    );

    if (purchaseOrder == null) {
      throw StateError(
        'Purchase Order tidak ditemukan.',
      );
    }

    final items =
        await _repository.getPurchaseOrderItems(
      purchaseOrderId,
    );

    return PurchaseOrderDetailState(
      purchaseOrder: purchaseOrder,
      items: items,
    );
  }

  Future<void> load(
    String purchaseOrderId,
  ) async {
    _purchaseOrderId = purchaseOrderId;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _load(purchaseOrderId),
    );
  }

  Future<void> refresh() async {
    final purchaseOrderId = _purchaseOrderId;

    if (purchaseOrderId == null) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _load(purchaseOrderId),
    );
  }

  Future<void> addItem(
    PurchaseOrderItem item,
  ) async {
    await _repository.addPurchaseOrderItem(item);

    await _syncPurchaseOrderTotals();

    await refresh();
  }

  Future<void> updateItem(
    PurchaseOrderItem item,
  ) async {
    final existingItem =
        await _findExistingItem(item.id);

    final receivedDelta =
        item.receivedQuantity -
            existingItem.receivedQuantity;

    if (item.receivedQuantity < 0) {
      throw StateError(
        'Jumlah diterima tidak boleh negatif.',
      );
    }

    if (item.receivedQuantity > item.quantity) {
      throw StateError(
        'Jumlah diterima tidak boleh melebihi jumlah order.',
      );
    }

    if (receivedDelta != 0) {
      await _updateProductStock(
        productId: item.productId,
        stockDelta: receivedDelta,
      );
    }

    await _repository.updatePurchaseOrderItem(
      item,
    );

    await _syncPurchaseOrderTotals();

    await refresh();
  }

  Future<void> deleteItem(
    String itemId,
  ) async {
    await _repository.deletePurchaseOrderItem(
      itemId,
    );

    await _syncPurchaseOrderTotals();

    await refresh();
  }

  Future<void> updatePurchaseOrder(
    PurchaseOrder purchaseOrder,
  ) async {
    await _repository.updatePurchaseOrder(
      purchaseOrder,
    );

    await refresh();
  }

  Future<void> _syncPurchaseOrderTotals() async {
    final purchaseOrderId = _purchaseOrderId;

    if (purchaseOrderId == null) {
      throw StateError(
        'Purchase Order ID belum ditentukan.',
      );
    }

    final purchaseOrder =
        await _repository.getPurchaseOrderById(
      purchaseOrderId,
    );

    if (purchaseOrder == null) {
      throw StateError(
        'Purchase Order tidak ditemukan.',
      );
    }

    final items =
        await _repository.getPurchaseOrderItems(
      purchaseOrderId,
    );

    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final total =
        subtotal -
            purchaseOrder.discount +
            purchaseOrder.tax;

    final updatedPurchaseOrder =
        purchaseOrder.copyWith(
      subtotal: subtotal,
      total: total,
      updatedAt: DateTime.now(),
    );

    await _repository.updatePurchaseOrder(
      updatedPurchaseOrder,
    );
  }

  Future<PurchaseOrderItem> _findExistingItem(
    String itemId,
  ) async {
    final purchaseOrderId = _purchaseOrderId;

    if (purchaseOrderId == null) {
      throw StateError(
        'Purchase Order ID belum ditentukan.',
      );
    }

    final items =
        await _repository.getPurchaseOrderItems(
      purchaseOrderId,
    );

    for (final item in items) {
      if (item.id == itemId) {
        return item;
      }
    }

    throw StateError(
      'Item Purchase Order tidak ditemukan.',
    );
  }

  Future<void> _updateProductStock({
    required String productId,
    required double stockDelta,
  }) async {
    if (stockDelta == 0) {
      return;
    }

    final product =
        await ref
            .read(productRepositoryProvider)
            .getProductById(
              productId,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw StateError(
                  'Timeout saat mengambil produk '
                  'dari Firestore.',
                );
              },
            );

    if (product == null) {
      throw StateError(
        'Produk dengan ID $productId '
        'tidak ditemukan di Inventory.',
      );
    }

    final newStock =
        product.stock + stockDelta;

    if (newStock < 0) {
      throw StateError(
        'Stok produk ${product.name} '
        'tidak boleh menjadi negatif.',
      );
    }

    final updatedProduct = Product(
      id: product.id,
      sku: product.sku,
      barcode: product.barcode,
      name: product.name,
      categoryId: product.categoryId,
      supplierId: product.supplierId,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      stock: newStock,
      minimumStock: product.minimumStock,
      imageUrl: product.imageUrl,
      businessType: product.businessType,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(
          productControllerProvider.notifier,
        )
        .updateProduct(updatedProduct);
  }
}