import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart';
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

  Stream<List<StockOpnameModel>> watchItemsByProduct(
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

  /// Menyimpan satu item Stock Opname secara atomik.
  ///
  /// Jika ada selisih, hasil opname, perubahan stok produk,
  /// dan Stock Adjustment disimpan dalam satu transaksi.
  ///
  /// Retry dengan ID serta isi transaksi yang sama dikenali
  /// melalui dokumen opname dan adjustment yang tersimpan.
  Future<void> saveItemAtomically({
    required StockOpnameModel item,
    StockAdjustmentModel? adjustment,
  }) async {
    final productRef = _firestore
        .collection('products')
        .doc(item.productId);

    final opnameRef = _collection.doc(item.id);

    final adjustmentRef = adjustment == null
        ? null
        : _adjustmentsCollection.doc(adjustment.id);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final existingOpname =
            await transaction.get(opnameRef);

        final existingAdjustment = adjustmentRef == null
            ? null
            : await transaction.get(adjustmentRef);

        // Retry dengan ID opname yang sama.
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

          if (!sameOpname) {
            throw StateError(
              'ID Stock Opname sudah digunakan '
              'oleh transaksi dengan data berbeda.',
            );
          }

          if (adjustment == null) {
            return;
          }

          final savedAdjustment =
              existingAdjustment?.data();

          if (savedAdjustment == null) {
            throw StateError(
              'Hasil opname sudah ditemukan, tetapi '
              'Stock Adjustment tidak ditemukan. '
              'Periksa konsistensi data sebelum mencoba lagi.',
            );
          }

          if (_sameAdjustment(
            savedAdjustment,
            adjustment,
          )) {
            // Transaksi identik sudah berhasil.
            // Jangan memperbarui stok untuk kedua kalinya.
            return;
          }

          throw StateError(
            'Stock Adjustment dengan ID yang sama '
            'memiliki data berbeda.',
          );
        }

        if (existingAdjustment?.exists ?? false) {
          throw StateError(
            'ID Stock Adjustment sudah digunakan '
            'oleh transaksi lain.',
          );
        }

        // Semua pembacaan dilakukan sebelum penulisan.
        final productSnapshot =
            await transaction.get(productRef);

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

        if (!currentStock.isFinite ||
            !item.stockSystem.isFinite ||
            !item.stockPhysical.isFinite ||
            !item.difference.isFinite) {
          throw StateError(
            'Nilai stok harus berupa angka yang valid.',
          );
        }

        if (item.stockPhysical < 0) {
          throw StateError(
            'Stok fisik tidak boleh negatif.',
          );
        }

        if (!_nearlyEqual(
          currentStock,
          item.stockSystem,
        )) {
          throw StateError(
            'Stok ${item.productName} telah berubah '
            'sejak opname dimulai. Muat ulang data dan '
            'lakukan opname kembali.',
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
          final expectedType =
              item.difference > 0 ? 'in' : 'out';

          final adjustmentMatches =
              adjustment.productId == item.productId &&
              adjustment.productName == item.productName &&
              adjustment.type.value == expectedType &&
              adjustment.reason.value == 'stock_opname' &&
              adjustment.referenceType == 'stock_opname' &&
              adjustment.referenceId == item.id &&
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

  bool _sameAdjustment(
    StockAdjustmentModel saved,
    StockAdjustmentModel requested,
  ) {
    return saved.productId == requested.productId &&
        saved.productName == requested.productName &&
        saved.type == requested.type &&
        saved.reason == requested.reason &&
        saved.notes == requested.notes &&
        saved.referenceType == requested.referenceType &&
        saved.referenceId == requested.referenceId &&
        saved.createdBy == requested.createdBy &&
        _nearlyEqual(
          saved.quantity,
          requested.quantity,
        ) &&
        _nearlyEqual(
          saved.stockBefore,
          requested.stockBefore,
        ) &&
        _nearlyEqual(
          saved.stockAfter,
          requested.stockAfter,
        );
  }

  bool _nearlyEqual(
    double first,
    double second,
  ) {
    return (first - second).abs() < 0.000001;
  }
}