import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductFirestoreDatasource {
  ProductFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<ProductModel> get _collection =>
      _firestore.collection('products').withConverter<ProductModel>(
            fromFirestore: ProductModel.fromFirestore,
            toFirestore: (model, options) =>
                model.toFirestore(options),
          );

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _collection
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  Stream<List<ProductModel>> watchProducts() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  Future<ProductModel?> getProductById(
    String id,
  ) async {
    final doc = await _collection.doc(id).get();

    return doc.data();
  }

  Future<void> addProduct(
    ProductModel product,
  ) async {
    await _collection
        .doc(product.id)
        .set(product);
  }

  Future<void> updateProduct(
    ProductModel product,
  ) async {
    await _collection
        .doc(product.id)
        .set(
          product.copyWith(
            updatedAt: DateTime.now(),
          ),
          SetOptions(
            merge: true,
          ),
        );
  }

  Future<void> deleteProduct(
    String id,
  ) async {
    await _collection
        .doc(id)
        .delete();
  }
}