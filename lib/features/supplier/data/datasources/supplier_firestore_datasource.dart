import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/supplier_model.dart';

class SupplierFirestoreDatasource {
  SupplierFirestoreDatasource();

  final CollectionReference<SupplierModel> _collection =
      FirebaseFirestore.instance
          .collection('suppliers')
          .withConverter<SupplierModel>(
            fromFirestore: SupplierModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore(),
          );

  Stream<List<SupplierModel>> watchSuppliers() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  Future<List<SupplierModel>> getSuppliers() async {
    final snapshot = await _collection.get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<SupplierModel?> getSupplierById(String id) async {
    final doc = await _collection.doc(id).get();

    return doc.data();
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    final doc = _collection.doc();

    await doc.set(
      supplier.copyWith(id: doc.id),
    );
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _collection.doc(supplier.id).set(supplier);
  }

  Future<void> deleteSupplier(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> toggleSupplierStatus({
    required String id,
    required bool isActive,
  }) async {
    await _collection.doc(id).update({
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<bool> existsByName(
    String name, {
    String? excludeId,
  }) async {
    final snapshot = await _collection
        .where('name', isEqualTo: name.trim())
        .limit(10)
        .get();

    for (final doc in snapshot.docs) {
      if (excludeId == null || doc.id != excludeId) {
        return true;
      }
    }

    return false;
  }
}