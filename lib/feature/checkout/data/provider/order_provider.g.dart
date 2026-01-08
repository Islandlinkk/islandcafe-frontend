// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderService)
const orderServiceProvider = OrderServiceProvider._();

final class OrderServiceProvider
    extends $FunctionalProvider<OrderService, OrderService, OrderService>
    with $Provider<OrderService> {
  const OrderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderServiceHash();

  @$internal
  @override
  $ProviderElement<OrderService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderService create(Ref ref) {
    return orderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderService>(value),
    );
  }
}

String _$orderServiceHash() => r'db91a1500c6ce21b07e5458d2b1d26fa20fe5df9';

@ProviderFor(orders)
const ordersProvider = OrdersProvider._();

final class OrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderModel>>,
          List<OrderModel>,
          FutureOr<List<OrderModel>>
        >
    with $FutureModifier<List<OrderModel>>, $FutureProvider<List<OrderModel>> {
  const OrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersHash();

  @$internal
  @override
  $FutureProviderElement<List<OrderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderModel>> create(Ref ref) {
    return orders(ref);
  }
}

String _$ordersHash() => r'af5a0d2a50993dcff9dd0cc3e83511266ee7aa2a';

@ProviderFor(OrderCreator)
const orderCreatorProvider = OrderCreatorProvider._();

final class OrderCreatorProvider
    extends $AsyncNotifierProvider<OrderCreator, OrderModel?> {
  const OrderCreatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderCreatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderCreatorHash();

  @$internal
  @override
  OrderCreator create() => OrderCreator();
}

String _$orderCreatorHash() => r'f6c47d5fafb7da89791ffb6256793eb8a8413696';

abstract class _$OrderCreator extends $AsyncNotifier<OrderModel?> {
  FutureOr<OrderModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<OrderModel?>, OrderModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OrderModel?>, OrderModel?>,
              AsyncValue<OrderModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
