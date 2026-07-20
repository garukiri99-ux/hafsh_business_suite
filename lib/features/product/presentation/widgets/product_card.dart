import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onAdjustStock,
  });

  final Product product;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAdjustStock;

  Color get _statusColor {
    if (!product.isActive) {
      return Colors.red;
    }

    if (product.stock <= product.minimumStock) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String get _statusText {
    if (!product.isActive) {
      return 'Nonaktif';
    }

    if (product.stock <= product.minimumStock) {
      return 'Stok Menipis';
    }

    return 'Aktif';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          child: Text(
            product.name.isEmpty
                ? '?'
                : product.name[0].toUpperCase(),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'SKU : ${product.sku}',
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                'Barcode : ${product.barcode.isEmpty ? "-" : product.barcode}',
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                'Stok : ${product.stock.toStringAsFixed(0)}',
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                'Min. Stok : ${product.minimumStock.toStringAsFixed(0)}',
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Rp ${product.sellingPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  _statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;

              case 'adjust':
                onAdjustStock?.call();
                break;

              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),

            const PopupMenuItem(
              value: 'adjust',
              child: Row(
                children: [
                  Icon(Icons.inventory),
                  SizedBox(width: 8),
                  Text('Adjust Stock'),
                ],
              ),
            ),

            const PopupMenuDivider(),

            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}