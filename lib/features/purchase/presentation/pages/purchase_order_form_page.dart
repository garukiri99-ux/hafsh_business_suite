import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../supplier/providers/supplier_provider.dart';
import '../../domain/entities/purchase_order.dart';
import '../providers/purchase_order_controller.dart';

class PurchaseOrderFormPage extends ConsumerStatefulWidget {
  const PurchaseOrderFormPage({
    super.key,
    this.purchaseOrder,
  });

  final PurchaseOrder? purchaseOrder;

  bool get isEdit => purchaseOrder != null;

  @override
  ConsumerState<PurchaseOrderFormPage> createState() =>
      _PurchaseOrderFormPageState();
}

class _PurchaseOrderFormPageState
    extends ConsumerState<PurchaseOrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numberController;
  late final TextEditingController _subtotalController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;
  late final TextEditingController _notesController;

  String? _selectedSupplierId;
  String? _selectedSupplierName;

  String _status = 'draft';
  DateTime _orderDate = DateTime.now();
  DateTime? _expectedDate;

  @override
  void initState() {
    super.initState();

    final order = widget.purchaseOrder;

    _numberController = TextEditingController(
      text: order?.number ?? '',
    );

    _subtotalController = TextEditingController(
      text: order?.subtotal.toString() ?? '0',
    );

    _discountController = TextEditingController(
      text: order?.discount.toString() ?? '0',
    );

    _taxController = TextEditingController(
      text: order?.tax.toString() ?? '0',
    );

    _notesController = TextEditingController(
      text: order?.notes ?? '',
    );

    _selectedSupplierId = order?.supplierId;
    _selectedSupplierName = order?.supplierName;

    _status = order?.status ?? 'draft';
    _orderDate = order?.orderDate ?? DateTime.now();
    _expectedDate = order?.expectedDate;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _subtotalController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  double _parseDouble(String value) {
    return double.tryParse(
          value.replaceAll(',', '.').trim(),
        ) ??
        0;
  }

  double get _subtotal =>
      _parseDouble(_subtotalController.text);

  double get _discount =>
      _parseDouble(_discountController.text);

  double get _tax =>
      _parseDouble(_taxController.text);

  double get _total =>
      _subtotal - _discount + _tax;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  Future<void> _selectOrderDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _orderDate = selected;

        if (_expectedDate != null &&
            _expectedDate!.isBefore(selected)) {
          _expectedDate = null;
        }
      });
    }
  }

  Future<void> _selectExpectedDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _expectedDate ?? _orderDate,
      firstDate: _orderDate,
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _expectedDate = selected;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final supplierId = _selectedSupplierId;
    final supplierName = _selectedSupplierName;

    if (supplierId == null ||
        supplierId.trim().isEmpty ||
        supplierName == null ||
        supplierName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Supplier wajib dipilih.',
          ),
        ),
      );

      return;
    }

    if (_discount < 0 || _tax < 0) {
      return;
    }

    if (_discount > _subtotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Diskon tidak boleh melebihi subtotal.',
          ),
        ),
      );

      return;
    }

    final existing = widget.purchaseOrder;

    final purchaseOrder = PurchaseOrder(
      id: existing?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      number: _numberController.text.trim(),
      supplierId: supplierId,
      supplierName: supplierName,
      status: _status,
      orderDate: _orderDate,
      expectedDate: _expectedDate,
      subtotal: _subtotal,
      discount: _discount,
      tax: _tax,
      total: _total,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdBy: existing?.createdBy,
      createdAt:
          existing?.createdAt ?? DateTime.now(),
      updatedAt:
          existing == null ? null : DateTime.now(),
    );

    final controller = ref.read(
      purchaseOrderControllerProvider.notifier,
    );

    try {
      if (widget.isEdit) {
        await controller.updatePurchaseOrder(
          purchaseOrder,
        );
      } else {
        await controller.addPurchaseOrder(
          purchaseOrder,
        );
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
            'Gagal menyimpan Purchase Order: $error',
          ),
        ),
      );
    }
  }

  Widget _buildSupplierField() {
    final suppliersAsync =
        ref.watch(supplierControllerProvider);

    return suppliersAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Supplier',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Memuat supplier...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Supplier',
              border: OutlineInputBorder(),
              errorText:
                  'Gagal memuat data supplier',
            ),
            child: const Text(
              'Data supplier tidak tersedia.',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                ref.invalidate(
                  supplierControllerProvider,
                );
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Muat Ulang',
              ),
            ),
          ),
        ],
      ),
      data: (suppliers) {
        if (suppliers.isEmpty) {
          return const InputDecorator(
            decoration: InputDecoration(
              labelText: 'Supplier',
              border: OutlineInputBorder(),
            ),
            child: Text(
              'Belum ada supplier.',
            ),
          );
        }

        final supplierIds =
            suppliers.map((supplier) => supplier.id).toSet();

        final initialSupplierId =
            supplierIds.contains(
          _selectedSupplierId,
        )
                ? _selectedSupplierId
                : null;

        return DropdownButtonFormField<String>(
          initialValue: initialSupplierId,
          decoration:
              _decoration('Supplier'),
          isExpanded: true,
          items: suppliers.map(
            (supplier) {
              return DropdownMenuItem<String>(
                value: supplier.id,
                child: Text(
                  supplier.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            final supplier = suppliers.firstWhere(
              (item) => item.id == value,
            );

            setState(() {
              _selectedSupplierId = supplier.id;
              _selectedSupplierName = supplier.name;
            });
          },
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Supplier wajib dipilih';
            }

            return null;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? 'Edit Purchase Order'
              : 'Purchase Order Baru',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _numberController,
              decoration:
                  _decoration('Nomor PO'),
              textInputAction:
                  TextInputAction.next,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nomor PO wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildSupplierField(),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: _decoration('Status'),
              items: const [
                DropdownMenuItem(
                  value: 'draft',
                  child: Text('Draft'),
                ),
                DropdownMenuItem(
                  value: 'ordered',
                  child: Text('Ordered'),
                ),
                DropdownMenuItem(
                  value: 'partial',
                  child: Text('Partial'),
                ),
                DropdownMenuItem(
                  value: 'received',
                  child: Text('Received'),
                ),
                DropdownMenuItem(
                  value: 'cancelled',
                  child: Text('Cancelled'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _status = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Tanggal Order',
              ),
              subtitle: Text(
                _formatDate(_orderDate),
              ),
              trailing: OutlinedButton(
                onPressed: _selectOrderDate,
                child: const Text('Pilih'),
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Tanggal Estimasi',
              ),
              subtitle: Text(
                _expectedDate == null
                    ? 'Belum ditentukan'
                    : _formatDate(
                        _expectedDate!,
                      ),
              ),
              trailing: OutlinedButton(
                onPressed: _selectExpectedDate,
                child: const Text('Pilih'),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subtotalController,
              decoration:
                  _decoration('Subtotal'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final subtotal =
                    _parseDouble(
                  value ?? '',
                );

                if (subtotal < 0) {
                  return 'Subtotal tidak boleh negatif';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountController,
              decoration:
                  _decoration('Diskon'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final discount =
                    _parseDouble(
                  value ?? '',
                );

                if (discount < 0) {
                  return 'Diskon tidak boleh negatif';
                }

                if (discount > _subtotal) {
                  return 'Diskon melebihi subtotal';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxController,
              decoration: _decoration('Pajak'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                final tax = _parseDouble(
                  value ?? '',
                );

                if (tax < 0) {
                  return 'Pajak tidak boleh negatif';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Rp ${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration:
                  _decoration('Catatan'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(
                widget.isEdit
                    ? 'Simpan Perubahan'
                    : 'Simpan Purchase Order',
              ),
            ),
          ],
        ),
      ),
    );
  }
}