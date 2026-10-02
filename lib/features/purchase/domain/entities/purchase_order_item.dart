class PurchaseOrderItem {
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

  const PurchaseOrderItem({
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

  double get remainingQuantity =>
      quantity - receivedQuantity;

  bool get isFullyReceived =>
      receivedQuantity >= quantity;

  bool get isPartiallyReceived =>
      receivedQuantity > 0 &&
      receivedQuantity < quantity;

  PurchaseOrderItem copyWith({
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
    return PurchaseOrderItem(
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
}