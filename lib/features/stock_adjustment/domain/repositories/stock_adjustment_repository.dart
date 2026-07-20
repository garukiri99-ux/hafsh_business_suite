import '../entities/stock_adjustment.dart';

abstract interface class StockAdjustmentRepository {
  Stream<List<StockAdjustment>> watchAdjustments();

  Stream<List<StockAdjustment>> watchAdjustmentsByProduct(
    String productId,
  );

  Future<List<StockAdjustment>> getAdjustments();

  Future<StockAdjustment?> getAdjustmentById(
    String id,
  );

  Future<void> addAdjustment(
    StockAdjustment adjustment,
  );

  Future<void> deleteAdjustment(
    String id,
  );
}