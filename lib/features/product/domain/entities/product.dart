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