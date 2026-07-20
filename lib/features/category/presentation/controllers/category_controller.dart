import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../providers/category_provider.dart';

class CategoryController extends StreamNotifier<List<Category>> {
  @override
  Stream<List<Category>> build() {
    return ref.watch(categoryRepositoryProvider).watchCategories();
  }

  Future<void> addCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).addCategory(category);
  }

  Future<void> updateCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(id);
  }

  Future<Category?> getCategoryById(String id) async {
    return ref.read(categoryRepositoryProvider).getCategoryById(id);
  }
}