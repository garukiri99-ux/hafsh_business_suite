import '../entities/product.dart';

abstract interface class ProductRepository {
  Stream<List<Product>> watchProducts();

  Future<List<Product>> getProducts();

  Future<Product?> getProductById(String id);

  Future<void> addProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String id);
}