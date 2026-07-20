import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../../providers/product_provider.dart';

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

    _purchasePriceController =
        TextEditingController(
      text: product?.purchasePrice.toString() ?? '',
    );

    _sellingPriceController =
        TextEditingController(
      text: product?.sellingPrice.toString() ?? '',
    );

    _stockController =
        TextEditingController(
      text: product?.stock.toString() ?? '0',
    );

    _minimumStockController =
        TextEditingController(
      text: product?.minimumStock.toString() ?? '0',
    );

    _isActive = product?.isActive ?? true;
  }

  String _generateSku() {
    final code = const Uuid().v4();

    return code.substring(0, 8).toUpperCase();
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

    final controller =
        ref.read(productControllerProvider.notifier);

    final now = DateTime.now();

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      sku: _skuController.text,
      barcode: _barcodeController.text,
      name: _nameController.text,
      categoryId: '',
      supplierId: '',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit Produk'
              : 'Tambah Produk',
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
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
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _purchasePriceController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga Beli',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _sellingPriceController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga Jual',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _stockController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  _minimumStockController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Stok',
              ),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
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

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
} 