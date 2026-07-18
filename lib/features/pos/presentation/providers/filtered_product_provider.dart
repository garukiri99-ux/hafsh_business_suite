import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import 'category_provider.dart';
import 'product_provider.dart';
import 'search_provider.dart';

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productProvider);
  final search = ref.watch(searchProvider).toLowerCase();
  final category = ref.watch(categoryProvider);

  return products.where((product) {
    final matchCategory =
        category == "Semua" || product.category == category;

    final matchSearch =
        product.name.toLowerCase().contains(search);

    return matchCategory && matchSearch;
  }).toList();
});