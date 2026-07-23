import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/category.dart';
import '../../providers/category_provider.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({
    super.key,
    this.category,
  });

  final Category? category;

  @override
  ConsumerState<CategoryFormPage> createState() =>
      _CategoryFormPageState();
}

class _CategoryFormPageState
    extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _isActive = true;

  bool get isEdit => widget.category != null;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller =
        ref.read(categoryControllerProvider.notifier);

    final now = DateTime.now();

    final category = Category(
      id: widget.category?.id ??
          const Uuid().v4(),
      name: _nameController.text.trim(),
      description:
          _descriptionController.text
                  .trim()
                  .isEmpty
              ? null
              : _descriptionController.text.trim(),
      isActive: _isActive,
      createdAt:
          widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEdit) {
      await controller.updateCategory(category);
    } else {
      await controller.addCategory(category);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit
              ? 'Kategori berhasil diperbarui'
              : 'Kategori berhasil ditambahkan',
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
              ? 'Edit Kategori'
              : 'Tambah Kategori',
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
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Biji Kopi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama kategori wajib diisi';
                }

                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText:
                    'Deskripsi kategori (opsional)',
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
                  'Kategori Aktif',
                ),
                subtitle: Text(
                  _isActive
                      ? 'Kategori dapat digunakan'
                      : 'Kategori dinonaktifkan',
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
                icon: const Icon(
                  Icons.save,
                ),
                label: Text(
                  isEdit
                      ? 'Update Kategori'
                      : 'Simpan Kategori',
                ),
              ),
            ),
         ],
        ),
      ),
    );
  }
}