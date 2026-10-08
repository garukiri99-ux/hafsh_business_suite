import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart'
    as core_inventory;
import '../../../product/domain/entities/product.dart';
import '../../../product/providers/product_provider.dart';
import '../../../stock_adjustment/domain/entities/stock_adjustment.dart';
import '../../../stock_adjustment/providers/stock_adjustment_provider.dart';
import '../../domain/entities/stock_opname_item.dart';
import '../../providers/stock_opname_provider.dart';

class StockOpnameFormPage extends ConsumerStatefulWidget {
  const StockOpnameFormPage({
    super.key,
  });

  @override
  ConsumerState<StockOpnameFormPage> createState() =>
      _StockOpnameFormPageState();
}

class _StockOpnameFormPageState
    extends ConsumerState<StockOpnameFormPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController>
      _controllers = {};

  final Map<String, TextEditingController>
      _noteControllers = {};

  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    for (final controller in _noteControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  TextEditingController _controllerFor(
    Product product,
  ) {
    return _controllers.putIfAbsent(
      product.id,
      () => TextEditingController(
        text: _formatNumber(product.stock),
      ),
    );
  }

  TextEditingController _noteControllerFor(
    Product product,
  ) {
    return _noteControllers.putIfAbsent(
      product.id,
      () => TextEditingController(),
    );
  }

  double _parseDouble(String value) {
    return double.tryParse(
          value.replaceAll(',', '.').trim(),
        ) ??
        0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  Future<void> _save(
    List<Product> products,
  ) async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final opnameItems = <StockOpnameItem>[];

    for (final product in products) {
      final controller =
          _controllers[product.id];

      if (controller == null) {
        continue;
      }

      final stockPhysical =
          _parseDouble(controller.text);

      final difference =
          stockPhysical - product.stock;

      final note =
          _noteControllers[product.id]?.text
                  .trim() ??
              '';

      opnameItems.add(
        StockOpnameItem(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          productId: product.id,
          productName: product.name,
          stockSystem: product.stock,
          stockPhysical: stockPhysical,
          difference: difference,
          notes: note,
          createdAt: DateTime.now(),
        ),
      );

      await Future<void>.delayed(
        const Duration(
          microseconds: 1,
        ),
      );
    }

    if (opnameItems.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada data Stock Opname yang diproses.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final opnameController = ref.read(
        stockOpnameControllerProvider.notifier,
      );

      final stockAdjustmentController =
          ref.read(
        stockAdjustmentControllerProvider.notifier,
      );

      final productController = ref.read(
        productControllerProvider.notifier,
      );

      for (final item in opnameItems) {
        await opnameController.addItem(item);

        if (!item.hasDifference) {
          continue;
        }

        final product =
            await ref
                .read(productRepositoryProvider)
                .getProductById(
                  item.productId,
                );

        if (product == null) {
          throw StateError(
            'Produk ${item.productName} tidak ditemukan.',
          );
        }

        final updatedProduct =
            product.copyWith(
          stock: item.stockPhysical,
          updatedAt: DateTime.now(),
        );

        await productController.updateProduct(
          updatedProduct,
        );

        final adjustmentType =
            item.difference > 0
                ? core_inventory
                    .StockAdjustmentType
                    .stockIn
                : core_inventory
                    .StockAdjustmentType
                    .stockOut;

        final adjustment =
            StockAdjustment(
          id: '${item.id}-adjustment',
          productId: item.productId,
          productName: item.productName,
          type: adjustmentType,
          quantity: item.difference.abs(),
          stockBefore: item.stockSystem,
          stockAfter: item.stockPhysical,
          reason: StockAdjustmentReason.stockOpname,
          notes: item.notes.trim().isEmpty
              ? 'Koreksi stok berdasarkan Stock Opname.'
              : item.notes.trim(),
          referenceType: 'stock_opname',
          referenceId: item.id,
          createdBy: null,
          createdAt: DateTime.now(),
        );

        await stockAdjustmentController.addAdjustment(
          adjustment,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${opnameItems.length} item Stock Opname berhasil disimpan.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(
            'Gagal menyimpan Stock Opname: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildProductCard(
    Product product,
  ) {
    final controller =
        _controllerFor(product);

    final noteController =
        _noteControllerFor(product);

    final stockPhysical =
        _parseDouble(controller.text);

    final difference =
        stockPhysical - product.stock;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stok Sistem'),
                Text(
                  _formatNumber(product.stock),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Stok Fisik',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final stock =
                    _parseDouble(value ?? '');

                if (stock < 0) {
                  return 'Stok tidak boleh negatif.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Selisih'),
                Text(
                  _formatDifference(
                    difference,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteController,
              maxLines: 2,
              decoration:
                  const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDifference(
    double value,
  ) {
    if (value == 0) {
      return '0';
    }

    final prefix = value > 0 ? '+' : '';

    return '$prefix${_formatNumber(value)}';
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(
      productControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Stock Opname',
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) =>
            Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gagal memuat produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada produk untuk di-opname.',
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                            _buildProductCard(
                          products[index],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () {
                                _save(
                                  products,
                                );
                              },
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),
                        label: Text(
                          _isSaving
                              ? 'Menyimpan...'
                              : 'Simpan Stock Opname',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}