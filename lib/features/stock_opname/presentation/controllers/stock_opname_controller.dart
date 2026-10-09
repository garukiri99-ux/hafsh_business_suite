import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../stock_adjustment/domain/entities/stock_adjustment.dart';
import '../../domain/entities/stock_opname_item.dart';
import '../../domain/repositories/stock_opname_repository.dart';
import '../../providers/stock_opname_provider.dart';

class StockOpnameController
    extends StreamNotifier<List<StockOpnameItem>> {
  StockOpnameRepository get _repository =>
      ref.read(stockOpnameRepositoryProvider);

  @override
  Stream<List<StockOpnameItem>> build() {
    return _repository.watchItems();
  }

  Future<void> addItem(
    StockOpnameItem item,
  ) async {
    await _repository.addItem(item);
  }

  Future<void> updateItem(
    StockOpnameItem item,
  ) async {
    await _repository.updateItem(item);
  }

  Future<void> deleteItem(
    String id,
  ) async {
    await _repository.deleteItem(id);
  }

  Future<StockOpnameItem?> getItemById(
    String id,
  ) {
    return _repository.getItemById(id);
  }

  /// Menyimpan hasil opname beserta koreksi stok
  /// dalam satu transaksi Firestore yang atomik.
  Future<void> saveItemAtomically({
    required StockOpnameItem item,
    StockAdjustment? adjustment,
  }) async {
    await _repository.saveItemAtomically(
      item: item,
      adjustment: adjustment,
    );
  }
}