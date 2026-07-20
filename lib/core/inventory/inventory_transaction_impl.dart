import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/product/data/models/product_model.dart';
import '../../features/stock_adjustment/data/models/stock_adjustment_model.dart';
import 'inventory_transaction.dart';

class InventoryTransactionImpl implements InventoryTransaction {
  InventoryTransactionImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> adjustStock({
    required String productId,
    required double quantity,
    required bool isStockIn,
    required String reason,
    String? notes,
    String? createdBy,
  }) async {
    final productRef = _firestore
        .collection('products')
        .withConverter<ProductModel>(
          fromFirestore: ProductModel.fromFirestore,
          toFirestore: (model, options) => model.toFirestore(options),
        )
        .doc(productId);

    final adjustmentRef = _firestore
        .collection('stock_adjustments')
        .withConverter<StockAdjustmentModel>(
          fromFirestore: StockAdjustmentModel.fromFirestore,
          toFirestore: (model, options) => model.toFirestore(options),
        )
        .doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      final product = snapshot.data();

      if (product == null) {
        throw Exception('Product tidak ditemukan.');
      }

      final stockBefore = product.stock;

      final stockAfter = isStockIn
          ? stockBefore + quantity
          : stockBefore - quantity;

      if (stockAfter < 0) {
        throw Exception('Stok tidak mencukupi.');
      }

      final updatedProduct = product.copyWith(
        stock: stockAfter,
        updatedAt: DateTime.now(),
      );

      transaction.set(
        productRef,
        updatedProduct,
      );

      final adjustment = StockAdjustmentModel(
        id: adjustmentRef.id,
        productId: product.id,
        type: isStockIn ? 'in' : 'out',
        quantity: quantity,
        stockBefore: stockBefore,
        stockAfter: stockAfter,
        reason: reason,
        notes: notes ?? '',
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      transaction.set(
        adjustmentRef,
        adjustment,
      );
    });
  }
}