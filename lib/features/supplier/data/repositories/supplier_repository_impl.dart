import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_firestore_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(this._datasource);

  final SupplierFirestoreDatasource _datasource;

  @override
  Stream<List<Supplier>> watchSuppliers() {
    return _datasource.watchSuppliers().map(
          (models) => models.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final models = await _datasource.getSuppliers();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Supplier?> getSupplierById(String id) async {
    final model = await _datasource.getSupplierById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addSupplier(Supplier supplier) {
    return _datasource.addSupplier(
      SupplierModel.fromEntity(supplier),
    );
  }

  @override
  Future<void> updateSupplier(Supplier supplier) {
    return _datasource.updateSupplier(
      SupplierModel.fromEntity(supplier),
    );
  }

  @override
  Future<void> deleteSupplier(String id) {
    return _datasource.deleteSupplier(id);
  }
}