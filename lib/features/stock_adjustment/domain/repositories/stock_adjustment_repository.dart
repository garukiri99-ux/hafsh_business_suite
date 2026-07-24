import '../entities/stock_adjustment.dart';

abstract interface class StockAdjustmentRepository {
  /// Seluruh riwayat adjustment.
  Stream<List<StockAdjustment>> watchAdjustments();

  /// Riwayat adjustment berdasarkan produk.
  Stream<List<StockAdjustment>> watchAdjustmentsByProduct(
    String productId,
  );

  /// Mengambil seluruh adjustment.
  Future<List<StockAdjustment>> getAdjustments();

  /// Mengambil adjustment berdasarkan ID.
  Future<StockAdjustment?> getAdjustmentById(
    String id,
  );

  /// Menambahkan adjustment baru.
  Future<void> addAdjustment(
    StockAdjustment adjustment,
  );

  /// Memperbarui adjustment.
  Future<void> updateAdjustment(
    StockAdjustment adjustment,
  );

  /// Menghapus adjustment.
  Future<void> deleteAdjustment(
    String id,
  );
}