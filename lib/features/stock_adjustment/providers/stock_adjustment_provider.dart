import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/stock_adjustment_firestore_datasource.dart';
import '../data/repositories/stock_adjustment_repository_impl.dart';
import '../domain/entities/stock_adjustment.dart';
import '../domain/repositories/stock_adjustment_repository.dart';
import '../presentation/controllers/stock_adjustment_controller.dart';

/// ===============================
/// Datasource
/// ===============================

final stockAdjustmentDatasourceProvider =
    Provider<StockAdjustmentFirestoreDatasource>((ref) {
  return StockAdjustmentFirestoreDatasource();
});

/// ===============================
/// Repository
/// ===============================

final stockAdjustmentRepositoryProvider =
    Provider<StockAdjustmentRepository>((ref) {
  return StockAdjustmentRepositoryImpl(
    ref.read(stockAdjustmentDatasourceProvider),
  );
});

/// ===============================
/// Controller
/// ===============================

final stockAdjustmentControllerProvider =
    StreamNotifierProvider<
        StockAdjustmentController,
        List<StockAdjustment>>(
  StockAdjustmentController.new,
);