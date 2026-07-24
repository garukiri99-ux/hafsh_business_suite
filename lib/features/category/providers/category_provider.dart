import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/category_firestore_datasource.dart';
import '../data/repositories/category_repository_impl.dart';
import '../domain/entities/category.dart';
import '../domain/repositories/category_repository.dart';
import '../presentation/controllers/category_controller.dart';

final categoryFirestoreDatasourceProvider =
    Provider<CategoryFirestoreDatasource>(
  (ref) => CategoryFirestoreDatasource(),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(
    ref.watch(categoryFirestoreDatasourceProvider),
  ),
);

final categoryControllerProvider =
    StreamNotifierProvider<CategoryController, List<Category>>(
  CategoryController.new,
);