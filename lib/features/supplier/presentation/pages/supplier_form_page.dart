import 'package:flutter/material.dart';

import '../../domain/entities/supplier.dart';

class SupplierFormPage extends StatefulWidget {
  const SupplierFormPage({
    super.key,
    this.supplier,
  });

  final Supplier? supplier;

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.supplier?.name ?? '');

    _contactController =
        TextEditingController(text: widget.supplier?.contactPerson ?? '');

    _phoneController =
        TextEditingController(text: widget.supplier?.phone ?? '');

    _emailController =
        TextEditingController(text: widget.supplier?.email ?? '');

    _addressController =
        TextEditingController(text: widget.supplier?.address ?? '');

    _isActive = widget.supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Supplier' : 'Tambah Supplier',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nama Supplier'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama supplier wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration:
                    const InputDecoration(labelText: 'Contact Person'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Nomor Telepon'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration:
                    const InputDecoration(labelText: 'Alamat'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}