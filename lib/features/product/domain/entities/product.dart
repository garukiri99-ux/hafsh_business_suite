import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String sku;
  final String barcode;
  final String name;

  final String categoryId;
  final String supplierId;

  final double purchasePrice;
  final double sellingPrice;

  final double stock;
  final double minimumStock;

  final String imageUrl;

  final String businessType;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.name,
    required this.categoryId,
    required this.supplierId,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minimumStock,
    required this.imageUrl,
    required this.businessType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? sku,
    String? barcode,
    String? name,
    String? categoryId,
    String? supplierId,
    double? purchasePrice,
    double? sellingPrice,
    double? stock,
    double? minimumStock,
    String? imageUrl,
    String? businessType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minimumStock: minimumStock ?? this.minimumStock,
      imageUrl: imageUrl ?? this.imageUrl,
      businessType: businessType ?? this.businessType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        barcode,
        name,
        categoryId,
        supplierId,
        purchasePrice,
        sellingPrice,
        stock,
        minimumStock,
        imageUrl,
        businessType,
        isActive,
        createdAt,
        updatedAt,
      ];
}