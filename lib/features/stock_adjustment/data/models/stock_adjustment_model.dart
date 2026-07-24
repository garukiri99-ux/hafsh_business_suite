import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart';
import '../../domain/entities/stock_adjustment.dart';

class StockAdjustmentModel extends StockAdjustment {
  const StockAdjustmentModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.type,
    required super.quantity,
    required super.stockBefore,
    required super.stockAfter,
    required super.reason,
    required super.notes,
    super.referenceType,
    super.referenceId,
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
      productName: adjustment.productName,
      type: adjustment.type,
      quantity: adjustment.quantity,
      stockBefore: adjustment.stockBefore,
      stockAfter: adjustment.stockAfter,
      reason: adjustment.reason,
      notes: adjustment.notes,
      referenceType: adjustment.referenceType,
      referenceId: adjustment.referenceId,
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
      productName: json['productName'] ?? '',
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
      referenceType: json['referenceType'],
      referenceId: json['referenceId'],
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
      'productName': productName,
      'type': type.value,
      'quantity': quantity,
      'stockBefore': stockBefore,
      'stockAfter': stockAfter,
      'reason': reason.value,
      'notes': notes,
      'referenceType': referenceType,
      'referenceId': referenceId,
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
      productName: productName,
      type: type,
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      reason: reason,
      notes: notes,
      referenceType: referenceType,
      referenceId: referenceId,
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
    String? productName,
    StockAdjustmentType? type,
    double? quantity,
    double? stockBefore,
    double? stockAfter,
    StockAdjustmentReason? reason,
    String? notes,
    String? referenceType,
    String? referenceId,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StockAdjustmentModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      stockBefore: stockBefore ?? this.stockBefore,
      stockAfter: stockAfter ?? this.stockAfter,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}