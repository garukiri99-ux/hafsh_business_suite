import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/stock_opname_firestore_datasource.dart';
import '../domain/entities/stock_opname_item.dart';
import '../domain/repositories/stock_opname_repository.dart';
import '../domain/repositories/stock_opname_repository_impl.dart';
import '../presentation/controllers/stock_opname_controller.dart';

final stockOpnameDatasourceProvider =
    Provider<StockOpnameFirestoreDatasource>((ref) {
  return StockOpnameFirestoreDatasource();
});

final stockOpnameRepositoryProvider =
    Provider<StockOpnameRepository>((ref) {
  return StockOpnameRepositoryImpl(
    ref.read(stockOpnameDatasourceProvider),
  );
});

final stockOpnameControllerProvider =
    StreamNotifierProvider<
        StockOpnameController,
        List<StockOpnameItem>>(
  StockOpnameController.new,
);