import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../stock_adjustment/data/models/stock_adjustment_model.dart';
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

  CollectionReference<StockAdjustmentModel>
      get _adjustmentsCollection =>
          _firestore
              .collection('stock_adjustments')
              .withConverter<StockAdjustmentModel>(
                fromFirestore:
                    StockAdjustmentModel.fromFirestore,
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
    final doc = await _collection.doc(id).get();

    return doc.data();
  }

  /// Menyimpan satu item opname secara atomik.
  ///
  /// Jika terdapat selisih, hasil opname, perubahan stok
  /// produk, dan Stock Adjustment disimpan bersama-sama.
  ///
  /// Jika transaksi gagal, Firestore membatalkan seluruh
  /// perubahan dalam transaksi tersebut.
  ///
  /// Untuk opname tanpa selisih, hanya hasil opname yang
  /// disimpan dan stok produk tidak diubah.
  Future<void> saveItemAtomically({
    required StockOpnameModel item,
    StockAdjustmentModel? adjustment,
  }) async {
    final productRef =
        _firestore.collection('products').doc(
              item.productId,
            );

    final opnameRef = _collection.doc(item.id);

    final adjustmentRef = adjustment == null
        ? null
        : _adjustmentsCollection.doc(adjustment.id);

    await _firestore.runTransaction<void>(
      (transaction) async {
        // Semua pembacaan dilakukan sebelum penulisan.
        final productSnapshot =
            await transaction.get(productRef);

        final existingOpname =
            await transaction.get(opnameRef);

        final existingAdjustment =
            adjustmentRef == null
                ? null
                : await transaction.get(
                    adjustmentRef,
                  );

        if (!productSnapshot.exists) {
          throw StateError(
            'Produk ${item.productName} tidak ditemukan.',
          );
        }

        final productData = productSnapshot.data();

        if (productData == null) {
          throw StateError(
            'Data produk ${item.productName} kosong.',
          );
        }

        final stockValue = productData['stock'];

        if (stockValue is! num) {
          throw StateError(
            'Nilai stok produk ${item.productName} '
            'tidak valid.',
          );
        }

        final currentStock = stockValue.toDouble();

        // Menangani retry dengan ID transaksi yang sama.
        // Jika transaksi sebelumnya sudah berhasil dengan
        // data yang identik, jangan mengoreksi stok lagi.
        if (existingOpname.exists) {
          final savedItem = existingOpname.data();

          final sameOpname = savedItem != null &&
              savedItem.productId == item.productId &&
              savedItem.productName == item.productName &&
              _nearlyEqual(
                savedItem.stockSystem,
                item.stockSystem,
              ) &&
              _nearlyEqual(
                savedItem.stockPhysical,
                item.stockPhysical,
              ) &&
              _nearlyEqual(
                savedItem.difference,
                item.difference,
              ) &&
              savedItem.notes == item.notes;

          final stockAlreadyApplied = _nearlyEqual(
            currentStock,
            item.stockPhysical,
          );

          final adjustmentAlreadySaved =
              adjustment == null ||
                  (existingAdjustment?.exists ?? false);

          if (sameOpname &&
              stockAlreadyApplied &&
              adjustmentAlreadySaved) {
            return;
          }

          throw StateError(
            'ID Stock Opname sudah digunakan oleh '
            'transaksi lain. Muat ulang data sebelum mencoba lagi.',
          );
        }

        // Cegah opname menggunakan stok sistem yang sudah
        // berubah sejak produk dimuat.
        if (!_nearlyEqual(
          currentStock,
          item.stockSystem,
        )) {
          throw StateError(
            'Stok ${item.productName} telah berubah '
            'sejak opname dimulai. Muat ulang data '
            'dan lakukan opname kembali.',
          );
        }

        final calculatedDifference =
            item.stockPhysical - item.stockSystem;

        if (!_nearlyEqual(
          calculatedDifference,
          item.difference,
        )) {
          throw StateError(
            'Nilai selisih Stock Opname tidak valid.',
          );
        }

        if (item.stockPhysical < 0) {
          throw StateError(
            'Stok fisik tidak boleh negatif.',
          );
        }

        if (item.hasDifference && adjustment == null) {
          throw StateError(
            'Stock Adjustment wajib disertakan '
            'ketika terdapat selisih stok.',
          );
        }

        if (!item.hasDifference && adjustment != null) {
          throw StateError(
            'Stock Adjustment tidak diperlukan '
            'jika tidak terdapat selisih stok.',
          );
        }

        if (adjustment != null) {
          final adjustmentMatches =
              adjustment.productId == item.productId &&
              _nearlyEqual(
                adjustment.quantity,
                item.difference.abs(),
              ) &&
              _nearlyEqual(
                adjustment.stockBefore,
                item.stockSystem,
              ) &&
              _nearlyEqual(
                adjustment.stockAfter,
                item.stockPhysical,
              );

          if (!adjustmentMatches) {
            throw StateError(
              'Data Stock Adjustment tidak cocok '
              'dengan hasil Stock Opname.',
            );
          }
        }

        // Penulisan dilakukan dalam satu transaksi.
        transaction.set(
          opnameRef,
          item,
        );

        if (adjustment != null) {
          transaction.update(
            productRef,
            {
              'stock': item.stockPhysical,
              'updatedAt': Timestamp.fromDate(
                DateTime.now(),
              ),
            },
          );

          transaction.set(
            adjustmentRef!,
            adjustment,
          );
        }
      },
    );
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

  bool _nearlyEqual(
    double first,
    double second,
  ) {
    return (first - second).abs() < 0.000001;
  }
}