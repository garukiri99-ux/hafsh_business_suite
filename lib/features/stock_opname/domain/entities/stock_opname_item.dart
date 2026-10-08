import 'package:equatable/equatable.dart';

class StockOpnameItem extends Equatable {
  const StockOpnameItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.stockSystem,
    required this.stockPhysical,
    required this.difference,
    required this.createdAt,
    this.notes = '',
  });

  final String id;

  final String productId;

  /// Snapshot nama produk saat opname dibuat.
  final String productName;

  /// Stok menurut sistem sebelum opname.
  final double stockSystem;

  /// Stok fisik hasil penghitungan.
  final double stockPhysical;

  /// Selisih antara stok fisik dan stok sistem.
  /// Nilai positif = stok bertambah.
  /// Nilai negatif = stok berkurang.
  final double difference;

  final String notes;

  final DateTime createdAt;

  bool get hasDifference => difference != 0;

  bool get isIncrease => difference > 0;

  bool get isDecrease => difference < 0;

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        stockSystem,
        stockPhysical,
        difference,
        notes,
        createdAt,
      ];
}