import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import 'product_form_page.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
      ),
      body: products.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada produk'),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = items[index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormPage(
                        product: product,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  child: Text(
                    product.name.isNotEmpty
                        ? product.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(product.name),
                subtitle: Text(product.sku),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stok: ${product.stock.toStringAsFixed(0)}',
                    ),
                    Text(
                      'Rp ${product.sellingPrice.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}