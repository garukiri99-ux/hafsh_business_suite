import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/product_firestore_datasource.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/product_repository.dart';
import '../presentation/controllers/product_controller.dart';

/// ===============================
/// Datasource
/// ===============================

final productDatasourceProvider =
    Provider<ProductFirestoreDatasource>((ref) {
  return ProductFirestoreDatasource();
});

/// ===============================
/// Repository
/// ===============================

final productRepositoryProvider =
    Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.read(productDatasourceProvider),
  );
});

/// ===============================
/// Controller
/// ===============================

final productControllerProvider =
    StreamNotifierProvider<ProductController, List<Product>>(
  ProductController.new,
);