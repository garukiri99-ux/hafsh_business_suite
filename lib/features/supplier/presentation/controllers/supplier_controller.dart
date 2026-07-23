import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/supplier.dart';
import '../../providers/supplier_provider.dart';

class SupplierController extends StreamNotifier<List<Supplier>> {
  @override
  Stream<List<Supplier>> build() {
    return ref.watch(supplierRepositoryProvider).watchSuppliers();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await ref.read(supplierRepositoryProvider).addSupplier(supplier);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await ref.read(supplierRepositoryProvider).updateSupplier(supplier);
  }

  Future<void> deleteSupplier(String id) async {
    await ref.read(supplierRepositoryProvider).deleteSupplier(id);
  }

  Future<Supplier?> getSupplierById(String id) async {
    return ref.read(supplierRepositoryProvider).getSupplierById(id);
  }

  Future<void> toggleSupplierStatus({
    required String id,
    required bool isActive,
  }) async {
    await ref.read(supplierRepositoryProvider).toggleSupplierStatus(
          id: id,
          isActive: isActive,
        );
  }

  Future<bool> existsByName(
    String name, {
    String? excludeId,
  }) {
    return ref.read(supplierRepositoryProvider).existsByName(
          name,
          excludeId: excludeId,
        );
  }
}