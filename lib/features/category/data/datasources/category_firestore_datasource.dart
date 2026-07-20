import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryFirestoreDatasource {
  CategoryFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<CategoryModel> get _collection =>
      _firestore.collection('categories').withConverter<CategoryModel>(
            fromFirestore: CategoryModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore(),
          );

  Stream<List<CategoryModel>> watchCategories() {
    return _collection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _collection.get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await _collection.doc(id).get();

    return doc.data();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _collection.doc(category.id).set(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _collection.doc(category.id).set(category);
  }

  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }
}