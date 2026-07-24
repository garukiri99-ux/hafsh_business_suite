import 'package:equatable/equatable.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart';

class StockAdjustment extends Equatable {
  const StockAdjustment({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.reason,
    required this.notes,
    this.referenceType,
    this.referenceId,
    this.createdBy,
    required this.createdAt,
  });

  final String id;

  /// ID produk.
  final String productId;

  /// Snapshot nama produk saat adjustment dibuat.
  final String productName;

  /// Jenis penyesuaian stok.
  final StockAdjustmentType type;

  /// Jumlah stok yang disesuaikan.
  final double quantity;

  /// Stok sebelum adjustment.
  final double stockBefore;

  /// Stok sesudah adjustment.
  final double stockAfter;

  /// Alasan adjustment.
  final StockAdjustmentReason reason;

  /// Catatan tambahan.
  final String notes;

  /// Contoh:
  /// PURCHASE
  /// SALE
  /// STOCK_OPNAME
  /// MANUAL
  final String? referenceType;

  /// Nomor referensi transaksi.
  /// Contoh:
  /// PO-00001
  /// INV-00025
  /// SO-00003
  final String? referenceId;

  /// UID atau nama pengguna yang melakukan adjustment.
  final String? createdBy;

  final DateTime createdAt;

  bool get isStockIn =>
      type == StockAdjustmentType.stockIn;

  bool get isStockOut =>
      type == StockAdjustmentType.stockOut;

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        type,
        quantity,
        stockBefore,
        stockAfter,
        reason,
        notes,
        referenceType,
        referenceId,
        createdBy,
        createdAt,
      ];
}