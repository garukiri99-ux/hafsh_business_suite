import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/category_provider.dart';
import '../widgets/category_card.dart';
import 'category_form_page.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
      ),
      body: categories.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada kategori'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => 
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = items[index];

              return CategoryCard(
                category: category,
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
              builder: (_) => const CategoryFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}