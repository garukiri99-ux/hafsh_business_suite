import '../../data/datasources/stock_opname_firestore_datasource.dart';
import '../../data/models/stock_opname_model.dart';
import '../entities/stock_opname_item.dart';
import 'stock_opname_repository.dart';

class StockOpnameRepositoryImpl
    implements StockOpnameRepository {
  StockOpnameRepositoryImpl(
    this._datasource,
  );

  final StockOpnameFirestoreDatasource _datasource;

  @override
  Stream<List<StockOpnameItem>> watchItems() {
    return _datasource.watchItems();
  }

  @override
  Stream<List<StockOpnameItem>>
      watchItemsByProduct(
    String productId,
  ) {
    return _datasource.watchItemsByProduct(
      productId,
    );
  }

  @override
  Future<List<StockOpnameItem>> getItems() async {
    return await _datasource.getItems();
  }

  @override
  Future<StockOpnameItem?> getItemById(
    String id,
  ) async {
    return await _datasource.getItemById(id);
  }

  @override
  Future<void> addItem(
    StockOpnameItem item,
  ) async {
    await _datasource.addItem(
      StockOpnameModel.fromEntity(item),
    );
  }

  @override
  Future<void> updateItem(
    StockOpnameItem item,
  ) async {
    await _datasource.updateItem(
      StockOpnameModel.fromEntity(item),
    );
  }

  @override
  Future<void> deleteItem(
    String id,
  ) async {
    await _datasource.deleteItem(id);
  }
}