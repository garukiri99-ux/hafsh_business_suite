import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/providers/product_provider.dart';
import '../../domain/entities/purchase_order_item.dart';
import '../providers/purchase_order_item_controller.dart';

class PurchaseOrderItemFormPage extends ConsumerStatefulWidget {
  const PurchaseOrderItemFormPage({
    super.key,
    required this.purchaseOrderId,
    this.item,
  });

  final String purchaseOrderId;
  final PurchaseOrderItem? item;

  bool get isEdit => item != null;

  @override
  ConsumerState<PurchaseOrderItemFormPage> createState() =>
      _PurchaseOrderItemFormPageState();
}

class _PurchaseOrderItemFormPageState
    extends ConsumerState<PurchaseOrderItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _productIdController;
  late final TextEditingController _productNameController;
  late final TextEditingController _skuController;
  late final TextEditingController _quantityController;
  late final TextEditingController _receivedQuantityController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _discountController;
  late final TextEditingController _notesController;

  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _productIdController = TextEditingController(
      text: item?.productId ?? '',
    );

    _productNameController = TextEditingController(
      text: item?.productName ?? '',
    );

    _skuController = TextEditingController(
      text: item?.sku ?? '',
    );

    _quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '1',
    );

    _receivedQuantityController =
        TextEditingController(
      text: item?.receivedQuantity.toString() ?? '0',
    );

    _unitCostController = TextEditingController(
      text: item?.unitCost.toString() ?? '0',
    );

    _discountController = TextEditingController(
      text: item?.discount.toString() ?? '0',
    );

    _notesController = TextEditingController(
      text: item?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _receivedQuantityController.dispose();
    _unitCostController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) {
    return double.tryParse(
          value.replaceAll(',', '.').trim(),
        ) ??
        0;
  }

  double get _quantity =>
      _parseDouble(_quantityController.text);

  double get _receivedQuantity =>
      _parseDouble(
        _receivedQuantityController.text,
      );

  double get _unitCost =>
      _parseDouble(_unitCostController.text);

  double get _discount =>
      _parseDouble(_discountController.text);

  double get _grossSubtotal =>
      _quantity * _unitCost;

  double get _subtotal =>
      _grossSubtotal - _discount;

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  Future<void> _selectProduct() async {
    final productsAsync =
        ref.read(productControllerProvider);

    await productsAsync.when(
      loading: () async {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        );
      },
      error: (error, stackTrace) async {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Gagal Memuat Produk',
              ),
              content: Text(
                error.toString(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
      data: (products) async {
        final activeProducts = products
            .where(
              (product) => product.isActive,
            )
            .toList();

        if (activeProducts.isEmpty) {
          await showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Belum Ada Produk',
                ),
                content: const Text(
                  'Belum ada produk aktif di Inventory.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tutup'),
                  ),
                ],
              );
            },
          );

          return;
        }

        final selected =
            await showDialog<Product>(
          context: context,
          builder: (dialogContext) {
            return _ProductSelectionDialog(
              products: activeProducts,
              selectedProduct: _selectedProduct,
            );
          },
        );

        if (selected == null || !mounted) {
          return;
        }

        setState(() {
          _selectedProduct = selected;

          _productIdController.text =
              selected.id;
          _productNameController.text =
              selected.name;
          _skuController.text = selected.sku;
          _unitCostController.text =
              selected.purchasePrice.toString();
        });
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_productIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih produk terlebih dahulu.',
          ),
        ),
      );

      return;
    }

    if (_receivedQuantity > _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jumlah diterima tidak boleh melebihi jumlah order.',
          ),
        ),
      );

      return;
    }

    if (_discount > _grossSubtotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Diskon tidak boleh melebihi nilai bruto item.',
          ),
        ),
      );

      return;
    }

    final existing = widget.item;

    final item = PurchaseOrderItem(
      id: existing?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      purchaseOrderId:
          widget.purchaseOrderId,
      productId:
          _productIdController.text.trim(),
      productName:
          _productNameController.text.trim(),
      sku: _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      quantity: _quantity,
      receivedQuantity:
          _receivedQuantity,
      unitCost: _unitCost,
      discount: _discount,
      subtotal: _subtotal,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final controller = ref.read(
      purchaseOrderItemControllerProvider.notifier,
    );

    try {
      if (widget.isEdit) {
        await controller.updateItem(item);
      } else {
        await controller.addItem(item);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan item: $error',
          ),
        ),
      );
    }
  }

  String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  Widget _buildProductSelector(
    AsyncValue<List<Product>> productsAsync,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _selectProduct,
          icon: const Icon(
            Icons.inventory_2_outlined,
          ),
          label: Text(
            _productNameController.text.trim().isEmpty
                ? 'Pilih Produk dari Inventory'
                : 'Ganti Produk',
          ),
        ),
        const SizedBox(height: 8),
        if (_productNameController.text
            .trim()
            .isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Icon(
                      Icons.inventory_2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productNameController
                              .text
                              .trim(),
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: '
                          '${_skuController.text.trim().isEmpty ? '-' : _skuController.text.trim()}',
                        ),
                        Text(
                          'Product ID: '
                          '${_productIdController.text.trim()}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        productsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Memuat data produk...',
            ),
          ),
          error: (error, stackTrace) =>
              Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Gagal memuat produk: $error',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          data: (products) {
            final activeCount = products
                .where(
                  (product) => product.isActive,
                )
                .length;

            return Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: Text(
                '$activeCount produk aktif tersedia.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(productControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? 'Edit Item Purchase Order'
              : 'Tambah Item Purchase Order',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProductSelector(
              productsAsync,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantityController,
              decoration:
                  _decoration('Jumlah Order'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final quantity = _parseDouble(
                  value ?? '',
                );

                if (quantity <= 0) {
                  return 'Jumlah order harus lebih dari 0';
                }

                if (_receivedQuantity > quantity) {
                  return 'Jumlah diterima melebihi jumlah order';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller:
                  _receivedQuantityController,
              decoration:
                  _decoration('Jumlah Diterima'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final received =
                    _parseDouble(value ?? '');

                if (received < 0) {
                  return 'Jumlah diterima tidak boleh negatif';
                }

                if (received > _quantity) {
                  return 'Jumlah diterima melebihi jumlah order';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _unitCostController,
              decoration:
                  _decoration('Harga Satuan'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final unitCost = _parseDouble(
                  value ?? '',
                );

                if (unitCost < 0) {
                  return 'Harga satuan tidak boleh negatif';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountController,
              decoration: _decoration('Diskon'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final discount = _parseDouble(
                  value ?? '',
                );

                if (discount < 0) {
                  return 'Diskon tidak boleh negatif';
                }

                if (discount > _grossSubtotal) {
                  return 'Diskon melebihi nilai item';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Item',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah'),
                        Text(
                          _formatNumber(
                            _quantity,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Harga Satuan',
                        ),
                        Text(
                          _formatRupiah(
                            _unitCost,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Diskon'),
                        Text(
                          _formatRupiah(
                            _discount,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatRupiah(
                            _subtotal,
                          ),
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: _decoration('Catatan'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(
                widget.isEdit
                    ? 'Simpan Perubahan'
                    : 'Simpan Item',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSelectionDialog extends StatefulWidget {
  const _ProductSelectionDialog({
    required this.products,
    this.selectedProduct,
  });

  final List<Product> products;
  final Product? selectedProduct;

  @override
  State<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState
    extends State<_ProductSelectionDialog> {
  final TextEditingController _searchController =
      TextEditingController();

  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final keyword =
        _keyword.trim().toLowerCase();

    if (keyword.isEmpty) {
      return widget.products;
    }

    return widget.products.where((product) {
      return product.name
              .toLowerCase()
              .contains(keyword) ||
          product.sku
              .toLowerCase()
              .contains(keyword) ||
          product.barcode
              .toLowerCase()
              .contains(keyword);
    }).toList();
  }

  String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return AlertDialog(
      title: const Text(
        'Pilih Produk',
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Cari nama, SKU, barcode...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _keyword = '';
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      ),
                border:
                    const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _keyword = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'Produk tidak ditemukan.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder:
                          (context, index) =>
                              const Divider(height: 1),
                      itemBuilder:
                          (context, index) {
                        final product =
                            products[index];

                        final isSelected =
                            widget.selectedProduct
                                    ?.id ==
                                product.id;

                        return ListTile(
                          selected: isSelected,
                          leading:
                              CircleAvatar(
                            child: const Icon(
                              Icons.inventory_2,
                            ),
                          ),
                          title: Text(
                            product.name,
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'SKU: ${product.sku}',
                              ),
                              Text(
                                'Stok: '
                                '${_formatNumber(product.stock)}',
                              ),
                              Text(
                                'Harga Beli: '
                                '${_formatRupiah(product.purchasePrice)}',
                              ),
                            ],
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(
                                      Icons
                                          .check_circle,
                                    )
                                  : null,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pop(product);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
      ],
    );
  }
}