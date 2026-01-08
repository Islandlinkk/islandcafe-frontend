// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoriteService)
const favoriteServiceProvider = FavoriteServiceProvider._();

final class FavoriteServiceProvider
    extends
        $FunctionalProvider<FavoriteService, FavoriteService, FavoriteService>
    with $Provider<FavoriteService> {
  const FavoriteServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteServiceHash();

  @$internal
  @override
  $ProviderElement<FavoriteService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FavoriteService create(Ref ref) {
    return favoriteService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteService>(value),
    );
  }
}

String _$favoriteServiceHash() => r'e0de971c6a7758e4c4f39712ebf306e64c8cecb6';

@ProviderFor(MyFavorites)
const myFavoritesProvider = MyFavoritesProvider._();

final class MyFavoritesProvider
    extends $AsyncNotifierProvider<MyFavorites, List<Favorite>> {
  const MyFavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myFavoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myFavoritesHash();

  @$internal
  @override
  MyFavorites create() => MyFavorites();
}

String _$myFavoritesHash() => r'efef849fc7c27405bd3f3a9124c2687ffbf8e575';

abstract class _$MyFavorites extends $AsyncNotifier<List<Favorite>> {
  FutureOr<List<Favorite>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Favorite>>, List<Favorite>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Favorite>>, List<Favorite>>,
              AsyncValue<List<Favorite>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
