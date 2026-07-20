import '../../domain/entities/stock_adjustment.dart';
import '../../domain/repositories/stock_adjustment_repository.dart';
import '../datasources/stock_adjustment_firestore_datasource.dart';
import '../models/stock_adjustment_model.dart';

class StockAdjustmentRepositoryImpl
    implements StockAdjustmentRepository {
  StockAdjustmentRepositoryImpl(
    this._datasource,
  );

  final StockAdjustmentFirestoreDatasource _datasource;

  @override
  Stream<List<StockAdjustment>> watchAdjustments() {
    return _datasource.watchAdjustments();
  }

  @override
  Stream<List<StockAdjustment>> watchAdjustmentsByProduct(
    String productId,
  ) {
    return _datasource.watchAdjustmentsByProduct(
      productId,
    );
  }

  @override
  Future<List<StockAdjustment>> getAdjustments() async {
    return await _datasource.getAdjustments();
  }

  @override
  Future<StockAdjustment?> getAdjustmentById(
    String id,
  ) async {
    return await _datasource.getAdjustmentById(
      id,
    );
  }

  @override
  Future<void> addAdjustment(
    StockAdjustment adjustment,
  ) async {
    await _datasource.addAdjustment(
      StockAdjustmentModel.fromEntity(
        adjustment,
      ),
    );
  }

  @override
  Future<void> deleteAdjustment(
    String id,
  ) async {
    await _datasource.deleteAdjustment(id);
  }
}