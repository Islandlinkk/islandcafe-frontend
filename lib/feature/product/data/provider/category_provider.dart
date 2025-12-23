
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/product/data/model/category_model.dart';
import 'package:island_cafe/feature/product/service/category_service.dart';

final categoryProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = CategoryService();
  final categories = await service.fetchCategories();
  return categories;
});