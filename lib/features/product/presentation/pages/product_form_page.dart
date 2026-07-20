import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../../providers/product_provider.dart';
import '../../../category/providers/category_provider.dart';
import '../../../supplier/providers/supplier_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({
    super.key,
    this.product,
  });

  @override
  ConsumerState<ProductFormPage> createState() =>
      _ProductFormPageState();
}

class _ProductFormPageState
    extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minimumStockController;

  bool _isActive = true;

  String? _selectedCategoryId;
  String? _selectedSupplierId;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController =
        TextEditingController(text: product?.name ?? '');

    _skuController = TextEditingController(
      text: product?.sku ?? _generateSku(),
    );

    _barcodeController =
        TextEditingController(text: product?.barcode ?? '');

    _purchasePriceController = TextEditingController(
      text: product?.purchasePrice.toString() ?? '',
    );

    _sellingPriceController = TextEditingController(
      text: product?.sellingPrice.toString() ?? '',
    );

    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );

    _minimumStockController = TextEditingController(
      text: product?.minimumStock.toString() ?? '0',
    );

    _isActive = product?.isActive ?? true;

    _selectedCategoryId = product?.categoryId;
    _selectedSupplierId = product?.supplierId;
  }

  String _generateSku() {
    return const Uuid()
        .v4()
        .substring(0, 8)
        .toUpperCase();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    if (double.tryParse(value) == null) {
      return 'Masukkan angka yang valid';
    }

    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null ||
        _selectedSupplierId == null) {
      return;
    }

    final controller =
        ref.read(productControllerProvider.notifier);

    final now = DateTime.now();

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      sku: _skuController.text.trim(),
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId!,
      supplierId: _selectedSupplierId!,
      purchasePrice:
          double.parse(_purchasePriceController.text),
      sellingPrice:
          double.parse(_sellingPriceController.text),
      stock: double.parse(_stockController.text),
      minimumStock:
          double.parse(_minimumStockController.text),
      imageUrl: '',
      businessType: 'coffee',
      isActive: _isActive,
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEdit) {
      await controller.updateProduct(product);
    } else {
      await controller.addProduct(product);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

    @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryControllerProvider);
    final suppliersAsync = ref.watch(supplierControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Produk' : 'Tambah Produk',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama produk wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            categoriesAsync.when(
  data: (categories) => DropdownButtonFormField<String>(
    initialValue: _selectedCategoryId,
    decoration: const InputDecoration(
      labelText: 'Kategori',
      border: OutlineInputBorder(),
    ),
    items: categories
        .map(
          (category) => DropdownMenuItem<String>(
            value: category.id,
            child: Text(category.name),
          ),
        )
        .toList(),
    onChanged: (value) {
      setState(() {
        _selectedCategoryId = value;
      });
    },
    validator: (value) {
      if (value == null) {
        return 'Kategori wajib dipilih';
      }
      return null;
    },
  ),
  loading: () => const Center(
    child: CircularProgressIndicator(),
  ),
  error: (error, stackTrace) => Text(
    'Error: $error',
  ),
),

            const SizedBox(height: 16),

            suppliersAsync.when(
  data: (suppliers) => DropdownButtonFormField<String>(
    initialValue: _selectedSupplierId,
    decoration: const InputDecoration(
      labelText: 'Supplier',
      border: OutlineInputBorder(),
    ),
    items: suppliers
        .map(
          (supplier) => DropdownMenuItem<String>(
            value: supplier.id,
            child: Text(supplier.name),
          ),
        )
        .toList(),
    onChanged: (value) {
      setState(() {
        _selectedSupplierId = value;
      });
    },
    validator: (value) {
      if (value == null) {
        return 'Supplier wajib dipilih';
      }
      return null;
    },
  ),
  loading: () => const Center(
    child: CircularProgressIndicator(),
  ),
  error: (error, stackTrace) => Text(
    'Error: $error',
  ),
),

            const SizedBox(height: 16),

            TextFormField(
              controller: _purchasePriceController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*$'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Harga Beli',
                border: OutlineInputBorder(),
              ),
              validator: _numberValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _sellingPriceController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*$'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Harga Jual',
                border: OutlineInputBorder(),
              ),
              validator: _numberValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _stockController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*$'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
              ),
              validator: _numberValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _minimumStockController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*$'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Minimum Stok',
                border: OutlineInputBorder(),
              ),
              validator: _numberValidator,
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              title: const Text(
                'Produk Aktif',
              ),
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(
                  isEdit
                      ? 'Update Produk'
                      : 'Simpan Produk',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}