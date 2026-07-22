import '../entities/category.dart';

abstract class CategoryRepository {
  /// Stream realtime kategori
  Stream<List<Category>> watchCategories();

  /// Mengambil seluruh kategori (sekali fetch)
  Future<List<Category>> getCategories();

  /// Mengambil kategori berdasarkan ID
  Future<Category?> getCategoryById(String id);

  /// Menambahkan kategori
  Future<void> addCategory(Category category);

  /// Mengubah kategori
  Future<void> updateCategory(Category category);

  /// Menghapus kategori
  Future<void> deleteCategory(String id);

  /// Mengubah status aktif/nonaktif
  Future<void> toggleCategoryStatus({
    required String id,
    required bool isActive,
  });

  /// Mengecek apakah nama kategori sudah ada
  Future<bool> existsByName(
    String name, {
    String? excludeId,
  });
}