// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$voucherServiceHash() => r'b5b02f521c2dfa9407380fc00f644954def141cf';
