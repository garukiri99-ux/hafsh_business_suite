import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/supplier_provider.dart';
import '../widgets/supplier_card.dart';
import 'supplier_form_page.dart';

class SupplierPage extends ConsumerWidget {
  const SupplierPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(supplierControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier'),
      ),
      body: suppliers.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada supplier'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final supplier = items[index];

              return SupplierCard(
                supplier: supplier,
                onTap: () {
                  // TODO: Halaman detail supplier
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupplierFormPage(
                        supplier: supplier,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Hapus Supplier'),
                      content: Text(
                        'Yakin ingin menghapus "${supplier.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(supplierControllerProvider.notifier)
                        .deleteSupplier(supplier.id);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SupplierFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}