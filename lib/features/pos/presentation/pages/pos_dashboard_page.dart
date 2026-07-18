import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/filtered_product_provider.dart';
import '../widgets/bottom_cart.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/search_box.dart';
import '../widgets/empty_product_state.dart';
import '../widgets/pos_app_bar.dart';

class PosDashboardPage extends ConsumerWidget {
  const PosDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: const PosAppBar(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Search
            const SearchBox(),

            const SizedBox(height: 16),

            /// Category
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    title: "Semua",
                    selected: selectedCategory == "Semua",
                    onTap: () {
                      ref.read(categoryProvider.notifier).setCategory("Semua");
                    },
                  ),

                  const SizedBox(width: 8),

                  CategoryChip(
                    title: "Coffee",
                    selected: selectedCategory == "Coffee",
                    onTap: () {
                      ref.read(categoryProvider.notifier).setCategory("Coffee");
                    },
                  ),

                  const SizedBox(width: 8),

                  CategoryChip(
                    title: "Non Coffee",
                    selected: selectedCategory == "Non Coffee",
                    onTap: () {
                      ref.read(categoryProvider.notifier).setCategory("Non Coffee");
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Product List
            Expanded(
              child: products.isEmpty
                  ? const EmptyProductState()
                  : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductCard(
                          product: product,
                          onAdd: () {
                            ref.read(cartProvider.notifier).add(product);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  duration:
                                      const Duration(milliseconds: 600),
                                  content: Text(
                                    "${product.name} ditambahkan",
                                  ),
                                ),
                              );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomCart(),
    );
  }
}