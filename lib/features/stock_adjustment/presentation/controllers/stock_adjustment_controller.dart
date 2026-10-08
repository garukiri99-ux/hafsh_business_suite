import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_adjustment.dart';
import '../../domain/repositories/stock_adjustment_repository.dart';
import '../../providers/stock_adjustment_provider.dart';

class StockAdjustmentController
    extends StreamNotifier<List<StockAdjustment>> {
  StockAdjustmentRepository get _repository =>
      ref.read(stockAdjustmentRepositoryProvider);

  @override
  Stream<List<StockAdjustment>> build() {
    return _repository.watchAdjustments();
  }

  Future<void> addAdjustment(
    StockAdjustment adjustment,
  ) async {
    await _repository.addAdjustment(adjustment);
  }

  Future<void> updateAdjustment(
    StockAdjustment adjustment,
  ) async {
    await _repository.updateAdjustment(adjustment);
  }

  Future<void> deleteAdjustment(
    String id,
  ) async {
    await _repository.deleteAdjustment(id);
  }

  Future<StockAdjustment?> getAdjustmentById(
    String id,
  ) {
    return _repository.getAdjustmentById(id);
  }
}