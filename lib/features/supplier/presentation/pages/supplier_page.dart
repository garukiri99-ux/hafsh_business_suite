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
              return SupplierCard(
                supplier: items[index],
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