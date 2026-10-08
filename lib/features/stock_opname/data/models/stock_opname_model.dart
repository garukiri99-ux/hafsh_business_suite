import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/stock_opname_item.dart';

class StockOpnameModel extends StockOpnameItem {
  const StockOpnameModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.stockSystem,
    required super.stockPhysical,
    required super.difference,
    required super.createdAt,
    super.notes,
  });

  factory StockOpnameModel.fromEntity(
    StockOpnameItem item,
  ) {
    return StockOpnameModel(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      stockSystem: item.stockSystem,
      stockPhysical: item.stockPhysical,
      difference: item.difference,
      notes: item.notes,
      createdAt: item.createdAt,
    );
  }

  factory StockOpnameModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    final createdAtValue = json['createdAt'];

    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    return StockOpnameModel(
      id: id,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      stockSystem:
          (json['stockSystem'] ?? 0).toDouble(),
      stockPhysical:
          (json['stockPhysical'] ?? 0).toDouble(),
      difference:
          (json['difference'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      createdAt: createdAt,
    );
  }

  factory StockOpnameModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data();

    if (data == null) {
      throw StateError(
        'Data Stock Opname tidak ditemukan.',
      );
    }

    return StockOpnameModel.fromJson(
      data,
      doc.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'stockSystem': stockSystem,
      'stockPhysical': stockPhysical,
      'difference': difference,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore(
    SetOptions? options,
  ) {
    return toJson();
  }

  StockOpnameItem toEntity() {
    return StockOpnameItem(
      id: id,
      productId: productId,
      productName: productName,
      stockSystem: stockSystem,
      stockPhysical: stockPhysical,
      difference: difference,
      notes: notes,
      createdAt: createdAt,
    );
  }
}