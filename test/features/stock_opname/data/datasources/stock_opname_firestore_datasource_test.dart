import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hafsh_business_suite/core/inventory/stock_adjustment_reason.dart';
import 'package:hafsh_business_suite/core/inventory/stock_adjustment_type.dart';
import 'package:hafsh_business_suite/features/stock_adjustment/data/models/stock_adjustment_model.dart';
import 'package:hafsh_business_suite/features/stock_adjustment/domain/entities/stock_adjustment.dart';
import 'package:hafsh_business_suite/features/stock_opname/data/datasources/stock_opname_firestore_datasource.dart';
import 'package:hafsh_business_suite/features/stock_opname/data/models/stock_opname_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StockOpnameFirestoreDatasource datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = StockOpnameFirestoreDatasource(
      firestore: firestore,
    );
  });

  group('Stock Opname atomic retry', () {
    test(
      'retry transaksi yang sama tidak menggandakan koreksi stok',
      () async {
        const productId = 'product-blend-37';
        const opnameId = 'opname-retry-001';
        const adjustmentId = '$opnameId-adjustment';

        final createdAt = DateTime.utc(2026, 10, 10, 6);

        await firestore
            .collection('products')
            .doc(productId)
            .set({
          'stock': 2.0,
          'updatedAt': Timestamp.fromDate(createdAt),
        });

        final item = StockOpnameModel(
          id: opnameId,
          productId: productId,
          productName: 'Blend 37',
          stockSystem: 2,
          stockPhysical: 1,
          difference: -1,
          notes: 'UAT retry atomik',
          createdAt: createdAt,
        );

        final adjustment = StockAdjustmentModel.fromEntity(
          StockAdjustment(
            id: adjustmentId,
            productId: productId,
            productName: 'Blend 37',
            type: StockAdjustmentType.stockOut,
            quantity: 1,
            stockBefore: 2,
            stockAfter: 1,
            reason: StockAdjustmentReason.stockOpname,
            notes: 'UAT retry atomik',
            referenceType: 'stock_opname',
            referenceId: opnameId,
            createdBy: null,
            createdAt: createdAt,
          ),
        );

        await datasource.saveItemAtomically(
          item: item,
          adjustment: adjustment,
        );

        // Retry dengan ID dan isi yang sama.
        await datasource.saveItemAtomically(
          item: item,
          adjustment: adjustment,
        );

        final productSnapshot = await firestore
            .collection('products')
            .doc(productId)
            .get();

        final opnameSnapshot = await firestore
            .collection('stock_opnames')
            .get();

        final adjustmentSnapshot = await firestore
            .collection('stock_adjustments')
            .get();

        expect(
          (productSnapshot.data()!['stock'] as num)
              .toDouble(),
          1.0,
        );

        expect(opnameSnapshot.docs, hasLength(1));
        expect(opnameSnapshot.docs.single.id, opnameId);

        expect(adjustmentSnapshot.docs, hasLength(1));
        expect(
          adjustmentSnapshot.docs.single.id,
          adjustmentId,
        );

        expect(
          adjustmentSnapshot.docs.single.data()['quantity'],
          1.0,
        );
      },
    );

    test(
      'opname tanpa selisih tidak mengubah stok saat diulang',
      () async {
        const productId = 'product-no-difference';
        const opnameId = 'opname-no-difference-001';

        final createdAt = DateTime.utc(2026, 10, 10, 7);

        await firestore
            .collection('products')
            .doc(productId)
            .set({
          'stock': 2.0,
          'updatedAt': Timestamp.fromDate(createdAt),
        });

        final item = StockOpnameModel(
          id: opnameId,
          productId: productId,
          productName: 'Blend 37',
          stockSystem: 2,
          stockPhysical: 2,
          difference: 0,
          notes: '',
          createdAt: createdAt,
        );

        await datasource.saveItemAtomically(item: item);
        await datasource.saveItemAtomically(item: item);

        final productSnapshot = await firestore
            .collection('products')
            .doc(productId)
            .get();

        final opnameSnapshot = await firestore
            .collection('stock_opnames')
            .get();

        final adjustmentSnapshot = await firestore
            .collection('stock_adjustments')
            .get();

        expect(
          (productSnapshot.data()!['stock'] as num)
              .toDouble(),
          2.0,
        );

        expect(opnameSnapshot.docs, hasLength(1));
        expect(adjustmentSnapshot.docs, isEmpty);
      },
    );
  });
}