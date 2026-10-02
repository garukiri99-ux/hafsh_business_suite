class PurchaseOrder {
  final String id;
  final String number;
  final String supplierId;
  final String supplierName;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDate;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PurchaseOrder({
    required this.id,
    required this.number,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.orderDate,
    this.expectedDate,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.notes,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isDraft => status == 'draft';

  bool get isOrdered => status == 'ordered';

  bool get isPartial => status == 'partial';

  bool get isReceived => status == 'received';

  bool get isCancelled => status == 'cancelled';

  PurchaseOrder copyWith({
    String? id,
    String? number,
    String? supplierId,
    String? supplierName,
    String? status,
    DateTime? orderDate,
    DateTime? expectedDate,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      number: number ?? this.number,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDate: expectedDate ?? this.expectedDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}