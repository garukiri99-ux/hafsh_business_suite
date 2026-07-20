import 'package:equatable/equatable.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart';

class StockAdjustment extends Equatable {
  final String id;

  final String productId;

  /// Jenis penyesuaian stok.
  final StockAdjustmentType type;

  final double quantity;

  final double stockBefore;

  final double stockAfter;

  /// Alasan penyesuaian stok.
  final StockAdjustmentReason reason;

  final String notes;

  final String? createdBy;

  final DateTime createdAt;

  const StockAdjustment({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.reason,
    required this.notes,
    this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        type,
        quantity,
        stockBefore,
        stockAfter,
        reason,
        notes,
        createdBy,
        createdAt,
      ];

  bool get isStockIn =>
      type == StockAdjustmentType.stockIn;

  bool get isStockOut =>
      type == StockAdjustmentType.stockOut;
}