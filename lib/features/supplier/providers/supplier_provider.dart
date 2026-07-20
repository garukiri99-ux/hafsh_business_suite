import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/supplier_firestore_datasource.dart';
import '../data/repositories/supplier_repository_impl.dart';
import '../domain/entities/supplier.dart';
import '../domain/repositories/supplier_repository.dart';
import '../presentation/controllers/supplier_controller.dart';

final supplierDatasourceProvider =
    Provider<SupplierFirestoreDatasource>((ref) {
  return SupplierFirestoreDatasource();
});

final supplierRepositoryProvider =
    Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(
    ref.watch(supplierDatasourceProvider),
  );
});

final supplierControllerProvider =
    StreamNotifierProvider<SupplierController, List<Supplier>>(
  SupplierController.new,
);