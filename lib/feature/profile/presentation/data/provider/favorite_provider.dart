import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:island_cafe/feature/profile/service/favorite_service.dart';

class FavoritesState {
  final List<dynamic> items;
  final bool isLoading;
  final String? error;

  FavoritesState({required this.items, this.isLoading = false, this.error});

  FavoritesState copyWith({List<dynamic>? items, bool? isLoading, String? error}) {
    return FavoritesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteService _service;
  final String userId;
  final SharedPreferences _prefs;

  FavoritesNotifier(this._service, this.userId, this._prefs)
      : super(FavoritesState(items: [], isLoading: true)) {
    _init();
  }

  String get _storageKey => 'favorites_$userId';

  Future<void> _init() async {
    // 1. Load local cache immediately for instant UI
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      state = state.copyWith(items: json.decode(raw), isLoading: false);
    }
    // 2. Sync with server silently
    await fetchRemote();
  }

  Future<void> fetchRemote() async {
    try {
      final remote = await _service.fetchFavorites(userId);
      state = state.copyWith(items: remote, isLoading: false);
      await _prefs.setString(_storageKey, json.encode(remote));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Sync failed");
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final productId = (product['id'] ?? product['_id']).toString();
    final isCurrentlyFav = isFavorite(productId);

    // OPTIMISTIC UPDATE
    final oldItems = List<dynamic>.from(state.items);
    final newItems = List<dynamic>.from(state.items);

    if (isCurrentlyFav) {
      newItems.removeWhere((item) => _extractId(item) == productId);
    } else {
      // Wrap product in a map to match the "nested" structure if your API does that
      newItems.add({'product': product, 'id': productId});
    }

    state = state.copyWith(items: newItems);

    try {
      bool success;
      if (isCurrentlyFav) {
        success = await _service.removeFavorite(userId, productId);
      } else {
        success = await _service.addFavorite(userId, productId);
      }
      if (success) {
        await _prefs.setString(_storageKey, json.encode(newItems));
      }
    } catch (e) {
      state = state.copyWith(items: oldItems); // Rollback on failure
    }
  }

  // Helper to find ID regardless of nesting
  String _extractId(dynamic item) {
    if (item is! Map) return '';
    if (item.containsKey('product')) {
      final p = item['product'];
      return (p['id'] ?? p['_id'] ?? '').toString();
    }
    return (item['id'] ?? item['_id'] ?? '').toString();
  }

  bool isFavorite(String productId) {
    return state.items.any((item) => _extractId(item) == productId);
  }
}

// Global Provider for SharedPreferences (Initialize this in main.dart)
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final favoritesProvider = StateNotifierProvider.family<FavoritesNotifier, FavoritesState, String>((ref, userId) {
  // Use a provider for the service too if possible
  final service = FavoriteService(); 
  final prefs = ref.watch(sharedPrefsProvider);
  return FavoritesNotifier(service, userId, prefs);
});