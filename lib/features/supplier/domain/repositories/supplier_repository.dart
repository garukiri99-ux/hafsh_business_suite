import '../entities/supplier.dart';

abstract class SupplierRepository {
  /// Stream realtime supplier
  Stream<List<Supplier>> watchSuppliers();

  /// Mengambil seluruh supplier (sekali fetch)
  Future<List<Supplier>> getSuppliers();

  /// Mengambil supplier berdasarkan ID
  Future<Supplier?> getSupplierById(String id);

  /// Menambahkan supplier
  Future<void> addSupplier(Supplier supplier);

  /// Mengubah supplier
  Future<void> updateSupplier(Supplier supplier);

  /// Menghapus supplier
  Future<void> deleteSupplier(String id);

  /// Mengubah status aktif/nonaktif
  Future<void> toggleSupplierStatus({
    required String id,
    required bool isActive,
  });

  /// Mengecek apakah nama supplier sudah ada
  Future<bool> existsByName(
    String name, {
    String? excludeId,
  });
}