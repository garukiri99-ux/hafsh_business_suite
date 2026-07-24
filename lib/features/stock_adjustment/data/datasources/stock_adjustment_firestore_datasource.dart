import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_adjustment_model.dart';

class StockAdjustmentFirestoreDatasource {
  StockAdjustmentFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<StockAdjustmentModel> get _collection =>
      _firestore
          .collection('stock_adjustments')
          .withConverter<StockAdjustmentModel>(
            fromFirestore: StockAdjustmentModel.fromFirestore,
            toFirestore: (model, options) =>
                model.toFirestore(options),
          );

  Future<List<StockAdjustmentModel>> getAdjustments() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  Stream<List<StockAdjustmentModel>> watchAdjustments() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  Stream<List<StockAdjustmentModel>>
      watchAdjustmentsByProduct(
    String productId,
  ) {
    return _collection
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  Future<StockAdjustmentModel?> getAdjustmentById(
    String id,
  ) async {
    final doc = await _collection.doc(id).get();

    return doc.data();
  }

  Future<void> addAdjustment(
    StockAdjustmentModel adjustment,
  ) async {
    await _collection
        .doc(adjustment.id)
        .set(adjustment);
  }

  Future<void> updateAdjustment(
    StockAdjustmentModel adjustment,
  ) async {
    await _collection
        .doc(adjustment.id)
        .update(adjustment.toJson());
  }

  Future<void> deleteAdjustment(
    String id,
  ) async {
    await _collection
        .doc(id)
        .delete();
  }
}