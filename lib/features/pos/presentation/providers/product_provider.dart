import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dummy_products.dart';
import '../../domain/entities/product.dart';

final productProvider = Provider<List<Product>>((ref) {
  return dummyProducts;
});