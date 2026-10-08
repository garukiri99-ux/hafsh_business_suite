import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_opname_model.dart';

class StockOpnameFirestoreDatasource {
  StockOpnameFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<StockOpnameModel> get _collection =>
      _firestore
          .collection('stock_opnames')
          .withConverter<StockOpnameModel>(
            fromFirestore:
                StockOpnameModel.fromFirestore,
            toFirestore: (model, options) =>
                model.toFirestore(options),
          );

  Future<List<StockOpnameModel>> getItems() async {
    final snapshot = await _collection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  Stream<List<StockOpnameModel>> watchItems() {
    return _collection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  Stream<List<StockOpnameModel>>
      watchItemsByProduct(
    String productId,
  ) {
    return _collection
        .where(
          'productId',
          isEqualTo: productId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  Future<StockOpnameModel?> getItemById(
    String id,
  ) async {
    final doc =
        await _collection.doc(id).get();

    return doc.data();
  }

  Future<void> addItem(
    StockOpnameModel item,
  ) async {
    await _collection
        .doc(item.id)
        .set(item);
  }

  Future<void> updateItem(
    StockOpnameModel item,
  ) async {
    await _collection
        .doc(item.id)
        .set(
          item,
          SetOptions(
            merge: true,
          ),
        );
  }

  Future<void> deleteItem(
    String id,
  ) async {
    await _collection
        .doc(id)
        .delete();
  }
}