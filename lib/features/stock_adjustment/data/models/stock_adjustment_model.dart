import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart';
import '../../domain/entities/stock_adjustment.dart';

class StockAdjustmentModel extends StockAdjustment {
  const StockAdjustmentModel({
    required super.id,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.stockBefore,
    required super.stockAfter,
    required super.reason,
    required super.notes,
    required super.createdBy,
    required super.createdAt,
  });

  /// ==========================
  /// Entity -> Model
  /// ==========================
  factory StockAdjustmentModel.fromEntity(
    StockAdjustment adjustment,
  ) {
    return StockAdjustmentModel(
      id: adjustment.id,
      productId: adjustment.productId,
      type: adjustment.type,
      quantity: adjustment.quantity,
      stockBefore: adjustment.stockBefore,
      stockAfter: adjustment.stockAfter,
      reason: adjustment.reason,
      notes: adjustment.notes,
      createdBy: adjustment.createdBy,
      createdAt: adjustment.createdAt,
    );
  }

  /// ==========================
  /// JSON -> Model
  /// ==========================
  factory StockAdjustmentModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return StockAdjustmentModel(
      id: id,
      productId: json['productId'] ?? '',
      type: StockAdjustmentTypeX.fromString(
        json['type'] ?? 'in',
      ),
      quantity: (json['quantity'] ?? 0).toDouble(),
      stockBefore: (json['stockBefore'] ?? 0).toDouble(),
      stockAfter: (json['stockAfter'] ?? 0).toDouble(),
      reason: StockAdjustmentReasonX.fromString(
        json['reason'] ?? 'manual',
      ),
      notes: json['notes'] ?? '',
      createdBy: json['createdBy'],
      createdAt:
          (json['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
    );
  }

  /// ==========================
  /// Firestore -> Model
  /// ==========================
  factory StockAdjustmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final json = doc.data()!;

    return StockAdjustmentModel.fromJson(
      json,
      doc.id,
    );
  }

  /// ==========================
  /// Model -> Firestore
  /// ==========================
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'type': type.value,
      'quantity': quantity,
      'stockBefore': stockBefore,
      'stockAfter': stockAfter,
      'reason': reason.value,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore(
    SetOptions? options,
  ) {
    return toJson();
  }

  /// ==========================
  /// Model -> Entity
  /// ==========================
  StockAdjustment toEntity() {
    return StockAdjustment(
      id: id,
      productId: productId,
      type: type,
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      reason: reason,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  /// ==========================
  /// Copy With
  /// ==========================
  StockAdjustmentModel copyWith({
    String? id,
    String? productId,
    StockAdjustmentType? type,
    double? quantity,
    double? stockBefore,
    double? stockAfter,
    StockAdjustmentReason? reason,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StockAdjustmentModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      stockBefore: stockBefore ?? this.stockBefore,
      stockAfter: stockAfter ?? this.stockAfter,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}