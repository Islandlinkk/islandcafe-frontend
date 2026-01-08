import 'package:firebase_auth/firebase_auth.dart';
import 'package:island_cafe/feature/product/data/model/favorite_model.dart';
import 'package:island_cafe/feature/product/service/favorite_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_provider.g.dart';

@riverpod
FavoriteService favoriteService(Ref ref) {
  return FavoriteService();
}

@riverpod
class MyFavorites extends _$MyFavorites {
  @override
  Future<List<Favorite>> build() async {
    // Get current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return []; // Return empty if not logged in

    // Fetch favorites from server
    final service = ref.read(favoriteServiceProvider);
    return await service.fetchFavorites(user.uid);
  }

  Future<void> addFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('You must be logged in');

    // Call API to add favorite
    final service = ref.read(favoriteServiceProvider);
    await service.addFavorite(user.uid, productId);

    // Refresh the list
    ref.invalidateSelf();
    await future;
  }

  Future<void> removeFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('You must be logged in');

    // Call API to remove favorite
    final service = ref.read(favoriteServiceProvider);
    await service.removeFavorite(user.uid, productId);

    // Refresh the list
    ref.invalidateSelf();
    await future;
  }

  bool isFavorite(String productId) {
    final favorites = state.value ?? [];
    return favorites.any((fav) => fav.product.id == productId);
  }
}
