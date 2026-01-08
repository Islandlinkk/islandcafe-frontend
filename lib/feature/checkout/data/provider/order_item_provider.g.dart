// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderItemService)
const orderItemServiceProvider = OrderItemServiceProvider._();

final class OrderItemServiceProvider
    extends
        $FunctionalProvider<
          OrderItemService,
          OrderItemService,
          OrderItemService
        >
    with $Provider<OrderItemService> {
  const OrderItemServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderItemServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderItemServiceHash();

  @$internal
  @override
  $ProviderElement<OrderItemService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderItemService create(Ref ref) {
    return orderItemService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderItemService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderItemService>(value),
    );
  }
}

String _$orderItemServiceHash() => r'1ab1b74e9c675538f10959b4531336373ef69e1c';

@ProviderFor(orderItems)
const orderItemsProvider = OrderItemsProvider._();

final class OrderItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderItemModel>>,
          List<OrderItemModel>,
          FutureOr<List<OrderItemModel>>
        >
    with
        $FutureModifier<List<OrderItemModel>>,
        $FutureProvider<List<OrderItemModel>> {
  const OrderItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<OrderItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderItemModel>> create(Ref ref) {
    return orderItems(ref);
  }
}

String _$orderItemsHash() => r'aebac0b522d7e5c92dd15b0db4d11c99f2e437d3';

@ProviderFor(OrderItemCreator)
const orderItemCreatorProvider = OrderItemCreatorProvider._();

final class OrderItemCreatorProvider
    extends $AsyncNotifierProvider<OrderItemCreator, OrderItemModel?> {
  const OrderItemCreatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderItemCreatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderItemCreatorHash();

  @$internal
  @override
  OrderItemCreator create() => OrderItemCreator();
}

String _$orderItemCreatorHash() => r'2b7bf0098aeb5efc5abe89a373018a051a172e50';

abstract class _$OrderItemCreator extends $AsyncNotifier<OrderItemModel?> {
  FutureOr<OrderItemModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<OrderItemModel?>, OrderItemModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OrderItemModel?>, OrderItemModel?>,
              AsyncValue<OrderItemModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
