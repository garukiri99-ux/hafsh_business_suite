import '../../domain/entities/purchase_order_item.dart';

class PurchaseOrderItemModel {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final String productName;
  final String? sku;
  final double quantity;
  final double receivedQuantity;
  final double unitCost;
  final double discount;
  final double subtotal;
  final String? notes;

  const PurchaseOrderItemModel({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.productName,
    this.sku,
    required this.quantity,
    this.receivedQuantity = 0,
    required this.unitCost,
    this.discount = 0,
    required this.subtotal,
    this.notes,
  });

  factory PurchaseOrderItemModel.fromEntity(
    PurchaseOrderItem entity,
  ) {
    return PurchaseOrderItemModel(
      id: entity.id,
      purchaseOrderId: entity.purchaseOrderId,
      productId: entity.productId,
      productName: entity.productName,
      sku: entity.sku,
      quantity: entity.quantity,
      receivedQuantity: entity.receivedQuantity,
      unitCost: entity.unitCost,
      discount: entity.discount,
      subtotal: entity.subtotal,
      notes: entity.notes,
    );
  }

  factory PurchaseOrderItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseOrderItemModel(
      id: json['id'] as String? ?? '',
      purchaseOrderId:
          json['purchaseOrderId'] as String? ?? '',
      productId:
          json['productId'] as String? ?? '',
      productName:
          json['productName'] as String? ?? '',
      sku: json['sku'] as String?,
      quantity: _parseDouble(
        json['quantity'],
      ),
      receivedQuantity: _parseDouble(
        json['receivedQuantity'],
      ),
      unitCost: _parseDouble(
        json['unitCost'],
      ),
      discount: _parseDouble(
        json['discount'],
      ),
      subtotal: _parseDouble(
        json['subtotal'],
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseOrderId': purchaseOrderId,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'quantity': quantity,
      'receivedQuantity': receivedQuantity,
      'unitCost': unitCost,
      'discount': discount,
      'subtotal': subtotal,
      'notes': notes,
    };
  }

  PurchaseOrderItem toEntity() {
    return PurchaseOrderItem(
      id: id,
      purchaseOrderId: purchaseOrderId,
      productId: productId,
      productName: productName,
      sku: sku,
      quantity: quantity,
      receivedQuantity: receivedQuantity,
      unitCost: unitCost,
      discount: discount,
      subtotal: subtotal,
      notes: notes,
    );
  }

  PurchaseOrderItemModel copyWith({
    String? id,
    String? purchaseOrderId,
    String? productId,
    String? productName,
    String? sku,
    double? quantity,
    double? receivedQuantity,
    double? unitCost,
    double? discount,
    double? subtotal,
    String? notes,
  }) {
    return PurchaseOrderItemModel(
      id: id ?? this.id,
      purchaseOrderId:
          purchaseOrderId ?? this.purchaseOrderId,
      productId: productId ?? this.productId,
      productName:
          productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      receivedQuantity:
          receivedQuantity ?? this.receivedQuantity,
      unitCost: unitCost ?? this.unitCost,
      discount: discount ?? this.discount,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
    );
  }

  static double _parseDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}