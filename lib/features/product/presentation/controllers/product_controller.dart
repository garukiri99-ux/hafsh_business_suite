import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../providers/product_provider.dart';

class ProductController
    extends StreamNotifier<List<Product>> {
  ProductRepository get _repository =>
      ref.read(productRepositoryProvider);

  @override
  Stream<List<Product>> build() {
    return _repository.watchProducts();
  }

  Future<void> addProduct(
    Product product,
  ) async {
    await _repository.addProduct(product);
  }

  Future<void> updateProduct(
    Product product,
  ) async {
    await _repository.updateProduct(product);
  }

  Future<void> deleteProduct(
    String id,
  ) async {
    await _repository.deleteProduct(id);
  }

  Future<Product?> getProductById(
    String id,
  ) async {
    return _repository.getProductById(id);
  }
}