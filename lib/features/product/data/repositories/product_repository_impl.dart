import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_firestore_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._datasource);

  final ProductFirestoreDatasource _datasource;

  @override
  Stream<List<Product>> watchProducts() {
    return _datasource.watchProducts();
  }

  @override
  Future<List<Product>> getProducts() async {
    return await _datasource.getProducts();
  }

  @override
  Future<Product?> getProductById(
    String id,
  ) async {
    return await _datasource.getProductById(id);
  }

  @override
  Future<void> addProduct(
    Product product,
  ) async {
    await _datasource.addProduct(
      ProductModel.fromEntity(product),
    );
  }

  @override
  Future<void> updateProduct(
    Product product,
  ) async {
    await _datasource.updateProduct(
      ProductModel.fromEntity(product),
    );
  }

  @override
  Future<void> deleteProduct(
    String id,
  ) async {
    await _datasource.deleteProduct(id);
  }
}