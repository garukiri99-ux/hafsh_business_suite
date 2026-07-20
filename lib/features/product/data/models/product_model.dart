import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.sku,
    required super.barcode,
    required super.name,
    required super.categoryId,
    required super.supplierId,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.stock,
    required super.minimumStock,
    required super.imageUrl,
    required super.businessType,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// ==========================
  /// Entity -> Model
  /// ==========================
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      sku: product.sku,
      barcode: product.barcode,
      name: product.name,
      categoryId: product.categoryId,
      supplierId: product.supplierId,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      stock: product.stock,
      minimumStock: product.minimumStock,
      imageUrl: product.imageUrl,
      businessType: product.businessType,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// ==========================
  /// JSON -> Model
  /// ==========================
  factory ProductModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return ProductModel(
      id: id,
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      supplierId: json['supplierId'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      stock: (json['stock'] ?? 0).toDouble(),
      minimumStock: (json['minimumStock'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      businessType: json['businessType'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt:
          (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// ==========================
  /// Firestore -> Model
  /// ==========================
  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final json = doc.data()!;

    return ProductModel.fromJson(
      json,
      doc.id,
    );
  }

  /// ==========================
  /// Model -> Firestore
  /// ==========================
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'barcode': barcode,
      'name': name,
      'categoryId': categoryId,
      'supplierId': supplierId,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'minimumStock': minimumStock,
      'imageUrl': imageUrl,
      'businessType': businessType,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
  Product toEntity() {
    return Product(
      id: id,
      sku: sku,
      barcode: barcode,
      name: name,
      categoryId: categoryId,
      supplierId: supplierId,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      stock: stock,
      minimumStock: minimumStock,
      imageUrl: imageUrl,
      businessType: businessType,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// ==========================
  /// Copy With
  /// ==========================
  ProductModel copyWith({
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
    return ProductModel(
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
}