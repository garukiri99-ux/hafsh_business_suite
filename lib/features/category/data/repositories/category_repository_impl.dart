import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_firestore_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._datasource);

  final CategoryFirestoreDatasource _datasource;

  @override
  Stream<List<Category>> watchCategories() {
    return _datasource.watchCategories().map(
          (categories) =>
              categories.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<List<Category>> getCategories() async {
    final categories = await _datasource.getCategories();
    return categories.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final category = await _datasource.getCategoryById(id);
    return category?.toEntity();
  }

  @override
  Future<void> addCategory(Category category) async {
    await _datasource.addCategory(
      CategoryModel.fromEntity(category),
    );
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _datasource.updateCategory(
      CategoryModel.fromEntity(category),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _datasource.deleteCategory(id);
  }

  @override
  Future<void> toggleCategoryStatus({
    required String id,
    required bool isActive,
  }) async {
    final category = await _datasource.getCategoryById(id);

    if (category == null) return;

    final updated = category.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    await _datasource.updateCategory(updated);
  }

  @override
  Future<bool> existsByName(
    String name, {
    String? excludeId,
  }) async {
    final categories = await _datasource.getCategories();

    return categories.any(
      (category) =>
          category.name.trim().toLowerCase() == name.trim().toLowerCase() &&
          category.id != excludeId,
    );
  }
}