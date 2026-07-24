import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/supplier_firestore_datasource.dart';
import '../data/repositories/supplier_repository_impl.dart';
import '../domain/entities/supplier.dart';
import '../domain/repositories/supplier_repository.dart';
import '../presentation/controllers/supplier_controller.dart';

final supplierFirestoreDatasourceProvider =
    Provider<SupplierFirestoreDatasource>(
  (ref) => SupplierFirestoreDatasource(),
);

final supplierRepositoryProvider =
    Provider<SupplierRepository>(
  (ref) => SupplierRepositoryImpl(
    ref.watch(supplierFirestoreDatasourceProvider),
  ),
);

final supplierControllerProvider =
    StreamNotifierProvider<
        SupplierController,
        List<Supplier>>(
  SupplierController.new,
);