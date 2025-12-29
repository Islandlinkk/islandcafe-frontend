
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:island_cafe/feature/product/data/model/product_model.dart';
import 'package:island_cafe/feature/product/service/product_service.dart';

final productProvider = FutureProvider<List<ProductModel>>((ref) async {
  final service = ProductService();
  final products = await service.fetchProducts();
  final activeProducts = products.where((product)=>product.status==true).toList();
  return activeProducts;
});

final selectedCategoryIdProvider = StateProvider<String>((ref) => '');
final selectedProductIdProvider = StateProvider<String>((ref) => '');
final searchQueryProvider = StateProvider<String>((ref) => '');
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

final productByCategoryProvider = FutureProvider<List<ProductModel>>((ref) async {
  final service = ProductService();
  final products = await service.fetchProducts();
  final activeProducts = products.where((product)=>product.status==true).toList();
  return activeProducts.where((product)=>product.categoryId==ref.watch(selectedCategoryIdProvider)).toList();
});

final productByIdProvider = FutureProvider<ProductModel>((ref) async {
  final service = ProductService();
  final product = await service.fetchProductsByProductId(ref.watch(selectedProductIdProvider));

  return product;
  });

final filteredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final products = await ref.watch(productProvider.future);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return products;
  }
  
  final query = searchQuery.toLowerCase();
  return products.where((product) {
    final nameMatch = product.name.toLowerCase().contains(query);
    final descriptionMatch = product.description.toLowerCase().contains(query);
    return nameMatch || descriptionMatch;
  }).toList();
});