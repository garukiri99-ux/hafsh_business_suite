import 'package:equatable/equatable.dart';

class StockAdjustment extends Equatable {
  final String id;

  final String productId;

  /// in | out
  final String type;

  final double quantity;

  final double stockBefore;

  final double stockAfter;

  /// restock | sold | damaged | expired | lost | manual
  final String reason;

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

  bool get isStockIn => type == 'in';

  bool get isStockOut => type == 'out';
}