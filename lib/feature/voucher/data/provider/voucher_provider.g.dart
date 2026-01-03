// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
const dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'a03da399b44b3740dc4fcfc6716203041d66ff01';

@ProviderFor(voucherService)
const voucherServiceProvider = VoucherServiceProvider._();

final class VoucherServiceProvider
    extends $FunctionalProvider<VoucherService, VoucherService, VoucherService>
    with $Provider<VoucherService> {
  const VoucherServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voucherServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voucherServiceHash();

  @$internal
  @override
  $ProviderElement<VoucherService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VoucherService create(Ref ref) {
    return voucherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoucherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoucherService>(value),
    );
  }
}

String _$voucherServiceHash() => r'ebbcdef1fbf09307b492fd0113f4f897dbdebbe2';

@ProviderFor(vouchers)
const vouchersProvider = VouchersProvider._();

final class VouchersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VoucherModel>>,
          List<VoucherModel>,
          FutureOr<List<VoucherModel>>
        >
    with
        $FutureModifier<List<VoucherModel>>,
        $FutureProvider<List<VoucherModel>> {
  const VouchersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vouchersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vouchersHash();

  @$internal
  @override
  $FutureProviderElement<List<VoucherModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VoucherModel>> create(Ref ref) {
    return vouchers(ref);
  }
}

String _$vouchersHash() => r'651f6cecce7f3bcddfee8f2f28ff743b07c499ae';
