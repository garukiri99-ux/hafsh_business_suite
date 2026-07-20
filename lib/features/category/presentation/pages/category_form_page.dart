import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    super.key,
    this.category,
  });

  final Category? category;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.category?.name ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );

    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Kategori' : 'Tambah Kategori',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                ),
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
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  isEdit ? 'Update' : 'Simpan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}