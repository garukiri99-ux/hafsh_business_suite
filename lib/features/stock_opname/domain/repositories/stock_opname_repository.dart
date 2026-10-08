import '../entities/stock_opname_item.dart';

abstract class StockOpnameRepository {
  Stream<List<StockOpnameItem>> watchItems();

  Stream<List<StockOpnameItem>> watchItemsByProduct(
    String productId,
  );

  Future<List<StockOpnameItem>> getItems();

  Future<StockOpnameItem?> getItemById(
    String id,
  );

  Future<void> addItem(
    StockOpnameItem item,
  );

  Future<void> updateItem(
    StockOpnameItem item,
  );

  Future<void> deleteItem(
    String id,
  );
}