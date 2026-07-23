import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/supplier.dart';
import '../../providers/supplier_provider.dart';

class SupplierFormPage extends ConsumerStatefulWidget {
  const SupplierFormPage({
    super.key,
    this.supplier,
  });

  final Supplier? supplier;

  @override
  ConsumerState<SupplierFormPage> createState() =>
      _SupplierFormPageState();
}

class _SupplierFormPageState
    extends ConsumerState<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _isActive = true;

  bool get isEdit => widget.supplier != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.supplier?.name ?? '',
    );

    _contactController = TextEditingController(
      text: widget.supplier?.contactPerson ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.supplier?.phone ?? '',
    );

    _emailController = TextEditingController(
      text: widget.supplier?.email ?? '',
    );

    _addressController = TextEditingController(
      text: widget.supplier?.address ?? '',
    );

    _notesController = TextEditingController(
      text: widget.supplier?.notes ?? '',
    );

    _isActive = widget.supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller =
        ref.read(supplierControllerProvider.notifier);

    final now = DateTime.now();

    final supplier = Supplier(
      id: widget.supplier?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      contactPerson:
          _contactController.text.trim().isEmpty
              ? null
              : _contactController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isActive: _isActive,
      createdAt: widget.supplier?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEdit) {
      await controller.updateSupplier(supplier);
    } else {
      await controller.addSupplier(supplier);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit
              ? 'Supplier berhasil diperbarui'
              : 'Supplier berhasil ditambahkan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit Supplier'
              : 'Tambah Supplier',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Supplier',
                hintText: 'Contoh: PT ABC Indonesia',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama supplier wajib diisi';
                }

                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _contactController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Contact Person',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Catatan supplier (opsional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: SwitchListTile(
                value: _isActive,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                title: const Text(
                  'Supplier Aktif',
                ),
                subtitle: Text(
                  _isActive
                      ? 'Supplier dapat digunakan'
                      : 'Supplier dinonaktifkan',
                ),
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(
                  isEdit
                      ? 'Update Supplier'
                      : 'Simpan Supplier',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}