import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/purchase_order_item_model.dart';
import '../../data/models/purchase_order_model.dart';
import '../entities/purchase_order.dart';
import '../entities/purchase_order_item.dart';
import 'purchase_repository.dart';

class PurchaseRepositoryImpl
    implements PurchaseRepository {
  PurchaseRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _ordersCollection =>
          _firestore.collection('purchase_orders');

  CollectionReference<Map<String, dynamic>>
      get _itemsCollection =>
          _firestore.collection(
            'purchase_order_items',
          );

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final snapshot =
        await _ordersCollection.get();

    return snapshot.docs
        .map(
          (doc) => PurchaseOrderModel.fromJson(
            {
              ...doc.data(),
              'id': doc.id,
            },
          ).toEntity(),
        )
        .toList();
  }

  @override
  Stream<List<PurchaseOrder>> watchPurchaseOrders() {
    return _ordersCollection
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PurchaseOrderModel.fromJson(
                  {
                    ...doc.data(),
                    'id': doc.id,
                  },
                ).toEntity(),
              )
              .toList(),
        );
  }

  @override
  Future<PurchaseOrder?> getPurchaseOrderById(
    String id,
  ) async {
    final doc =
        await _ordersCollection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return PurchaseOrderModel.fromJson(
      {
        ...doc.data()!,
        'id': doc.id,
      },
    ).toEntity();
  }

  @override
  Future<List<PurchaseOrderItem>> getPurchaseOrderItems(
    String purchaseOrderId,
  ) async {
    final snapshot = await _itemsCollection
        .where(
          'purchaseOrderId',
          isEqualTo: purchaseOrderId,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              PurchaseOrderItemModel.fromJson(
            {
              ...doc.data(),
              'id': doc.id,
            },
          ).toEntity(),
        )
        .toList();
  }

  @override
  Future<void> addPurchaseOrder(
    PurchaseOrder purchaseOrder,
  ) async {
    final model =
        PurchaseOrderModel.fromEntity(
      purchaseOrder,
    );

    await _ordersCollection
        .doc(purchaseOrder.id)
        .set(model.toJson());
  }

  @override
  Future<void> updatePurchaseOrder(
    PurchaseOrder purchaseOrder,
  ) async {
    final doc =
        _ordersCollection.doc(purchaseOrder.id);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      throw StateError(
        'Purchase order tidak ditemukan.',
      );
    }

    final model =
        PurchaseOrderModel.fromEntity(
      purchaseOrder,
    );

    await doc.set(
      model.toJson(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deletePurchaseOrder(
    String id,
  ) async {
    final batch = _firestore.batch();

    final itemSnapshot = await _itemsCollection
        .where(
          'purchaseOrderId',
          isEqualTo: id,
        )
        .get();

    for (final item in itemSnapshot.docs) {
      batch.delete(item.reference);
    }

    batch.delete(
      _ordersCollection.doc(id),
    );

    await batch.commit();
  }

  @override
  Future<void> addPurchaseOrderItem(
    PurchaseOrderItem item,
  ) async {
    final model =
        PurchaseOrderItemModel.fromEntity(item);

    await _itemsCollection
        .doc(item.id)
        .set(model.toJson());
  }

  @override
  Future<void> updatePurchaseOrderItem(
    PurchaseOrderItem item,
  ) async {
    final doc =
        _itemsCollection.doc(item.id);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      throw StateError(
        'Item purchase order tidak ditemukan.',
      );
    }

    final model =
        PurchaseOrderItemModel.fromEntity(item);

    await doc.set(
      model.toJson(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deletePurchaseOrderItem(
    String id,
  ) async {
    await _itemsCollection.doc(id).delete();
  }
}