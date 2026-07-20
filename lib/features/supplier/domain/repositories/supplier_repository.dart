import '../entities/supplier.dart';

abstract class SupplierRepository {
  Stream<List<Supplier>> watchSuppliers();

  Future<List<Supplier>> getSuppliers();

  Future<Supplier?> getSupplierById(String id);

  Future<void> addSupplier(Supplier supplier);

  Future<void> updateSupplier(Supplier supplier);

  Future<void> deleteSupplier(String id);
}