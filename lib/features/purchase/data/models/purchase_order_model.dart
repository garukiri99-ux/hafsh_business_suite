import '../../domain/entities/purchase_order.dart';

class PurchaseOrderModel {
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

  const PurchaseOrderModel({
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

  factory PurchaseOrderModel.fromEntity(
    PurchaseOrder entity,
  ) {
    return PurchaseOrderModel(
      id: entity.id,
      number: entity.number,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      status: entity.status,
      orderDate: entity.orderDate,
      expectedDate: entity.expectedDate,
      subtotal: entity.subtotal,
      discount: entity.discount,
      tax: entity.tax,
      total: entity.total,
      notes: entity.notes,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PurchaseOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseOrderModel(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      supplierId: json['supplierId'] as String? ?? '',
      supplierName:
          json['supplierName'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      orderDate: _parseDate(
        json['orderDate'],
      ),
      expectedDate: _parseNullableDate(
        json['expectedDate'],
      ),
      subtotal: _parseDouble(
        json['subtotal'],
      ),
      discount: _parseDouble(
        json['discount'],
      ),
      tax: _parseDouble(
        json['tax'],
      ),
      total: _parseDouble(
        json['total'],
      ),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: _parseDate(
        json['createdAt'],
      ),
      updatedAt: _parseNullableDate(
        json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'expectedDate':
          expectedDate?.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  PurchaseOrder toEntity() {
    return PurchaseOrder(
      id: id,
      number: number,
      supplierId: supplierId,
      supplierName: supplierName,
      status: status,
      orderDate: orderDate,
      expectedDate: expectedDate,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PurchaseOrderModel copyWith({
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
    return PurchaseOrderModel(
      id: id ?? this.id,
      number: number ?? this.number,
      supplierId: supplierId ?? this.supplierId,
      supplierName:
          supplierName ?? this.supplierName,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDate:
          expectedDate ?? this.expectedDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDate(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _parseNullableDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    return null;
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