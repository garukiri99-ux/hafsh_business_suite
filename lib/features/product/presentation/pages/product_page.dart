import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart'
    as core_inventory;
import '../../../stock_adjustment/domain/entities/stock_adjustment.dart';
import '../../../stock_adjustment/presentation/dialogs/stock_adjustment_dialog.dart';
import '../../../stock_adjustment/providers/stock_adjustment_provider.dart';
import '../../domain/entities/product.dart';
import '../../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_chip.dart';
import '../widgets/product_search.dart';
import 'product_form_page.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key});

  @override
  ConsumerState<ProductPage> createState() =>
      _ProductPageState();
}

class _ProductPageState
    extends ConsumerState<ProductPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _keyword = '';

  int _selectedFilter = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct(
    Product product,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Hapus Produk',
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Batal',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await ref
        .read(productControllerProvider.notifier)
        .deleteProduct(product.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} berhasil dihapus',
        ),
      ),
    );
  }

  List<Product> _filterProducts(
    List<Product> products,
  ) {
    Iterable<Product> filtered = products;

    if (_keyword.trim().isNotEmpty) {
      final keyword = _keyword.toLowerCase();

      filtered = filtered.where(
        (product) {
          return product.name
                  .toLowerCase()
                  .contains(keyword) ||
              product.sku
                  .toLowerCase()
                  .contains(keyword) ||
              product.barcode
                  .toLowerCase()
                  .contains(keyword);
        },
      );
    }

    switch (_selectedFilter) {
      case 1:
        filtered = filtered.where(
          (product) => product.isActive,
        );
        break;

      case 2:
        filtered = filtered.where(
          (product) => !product.isActive,
        );
        break;

      case 3:
        filtered = filtered.where(
          (product) =>
              product.stock <=
              product.minimumStock,
        );
        break;
    }

    return filtered.toList();
  }

  void _openForm([
    Product? product,
  ]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          product: product,
        ),
      ),
    );
  }

  Future<void> _showAdjustStockDialog(
    Product product,
  ) async {
    final result =
        await showDialog<StockAdjustmentResult>(
      context: context,
      builder: (_) => StockAdjustmentDialog(
        productName: product.name,
        currentStock: product.stock,
      ),
    );

    if (result == null) return;

    final stockBefore = product.stock;
    double stockAfter;

    core_inventory.StockAdjustmentType
        adjustmentType;

    switch (result.type) {
      case StockAdjustmentType.add:
        stockAfter =
            stockBefore + result.quantity;
        adjustmentType =
            core_inventory.StockAdjustmentType.stockIn;
        break;

      case StockAdjustmentType.subtract:
        stockAfter =
            stockBefore - result.quantity;
        adjustmentType =
            core_inventory.StockAdjustmentType.stockOut;
        break;

      case StockAdjustmentType.set:
        stockAfter = result.quantity;

        if (stockAfter > stockBefore) {
          adjustmentType =
              core_inventory.StockAdjustmentType.stockIn;
        } else if (stockAfter < stockBefore) {
          adjustmentType =
              core_inventory.StockAdjustmentType.stockOut;
        } else {
          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak ada perubahan stok.',
              ),
            ),
          );

          return;
        }
        break;
    }

    if (stockAfter < 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stok tidak boleh menjadi negatif.',
          ),
        ),
      );

      return;
    }

    final changedQuantity =
        (stockAfter - stockBefore).abs();

    final updatedProduct = Product(
      id: product.id,
      sku: product.sku,
      barcode: product.barcode,
      name: product.name,
      categoryId: product.categoryId,
      supplierId: product.supplierId,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      stock: stockAfter,
      minimumStock: product.minimumStock,
      imageUrl: product.imageUrl,
      businessType: product.businessType,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await ref
          .read(
            productControllerProvider.notifier,
          )
          .updateProduct(updatedProduct);

      final adjustment = StockAdjustment(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        productId: product.id,
        productName: product.name,
        type: adjustmentType,
        quantity: changedQuantity,
        stockBefore: stockBefore,
        stockAfter: stockAfter,
        reason: StockAdjustmentReason.manual,
        notes: result.note.trim().isEmpty
            ? 'Penyesuaian stok manual.'
            : result.note.trim(),
        referenceType: 'manual_adjustment',
        referenceId: product.id,
        createdBy: null,
        createdAt: DateTime.now(),
      );

      await ref
          .read(
            stockAdjustmentControllerProvider
                .notifier,
          )
          .addAdjustment(adjustment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok "${product.name}" berhasil '
            'diubah dari ${_formatStock(stockBefore)} '
            'menjadi ${_formatStock(stockAfter)}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyesuaikan stok: $error',
          ),
        ),
      );
    }
  }

  String _formatStock(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(productControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Produk',
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah',
        ),
      ),
      body: Column(
        children: [
          ProductSearch(
            controller: _searchController,
            keyword: _keyword,
            onChanged: (value) {
              setState(() {
                _keyword = value;
              });
            },
            onClear: () {
              _searchController.clear();

              setState(() {
                _keyword = '';
              });
            },
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                ProductFilterChip(
                  label: 'Semua',
                  icon: Icons.inventory_2,
                  selected: _selectedFilter == 0,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = 0;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ProductFilterChip(
                  label: 'Aktif',
                  icon: Icons.check_circle,
                  selected: _selectedFilter == 1,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = 1;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ProductFilterChip(
                  label: 'Nonaktif',
                  icon: Icons.block,
                  selected: _selectedFilter == 2,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = 2;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ProductFilterChip(
                  label: 'Stok Menipis',
                  icon: Icons.warning_amber,
                  selected: _selectedFilter == 3,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = 3;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) {
                return Center(
                  child: Text(
                    error.toString(),
                  ),
                );
              },
              data: (products) {
                final items =
                    _filterProducts(products);

                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(
                        productControllerProvider,
                      );
                    },
                    child: ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Belum ada produk',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Tekan tombol + untuk menambah produk',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      productControllerProvider,
                    );
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder:
                        (context, index) {
                      final product =
                          items[index];

                      return ProductCard(
                        product: product,
                        onTap: () {
                          _openForm(product);
                        },
                        onEdit: () {
                          _openForm(product);
                        },
                        onDelete: () {
                          _deleteProduct(product);
                        },
                        onAdjustStock: () {
                          _showAdjustStockDialog(
                            product,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}