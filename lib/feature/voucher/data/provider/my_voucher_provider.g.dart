// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_voucher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyVouchers)
const myVouchersProvider = MyVouchersProvider._();

final class MyVouchersProvider
    extends $NotifierProvider<MyVouchers, List<VoucherModel>> {
  const MyVouchersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myVouchersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myVouchersHash();

  @$internal
  @override
  MyVouchers create() => MyVouchers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<VoucherModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<VoucherModel>>(value),
    );
  }
}

String _$myVouchersHash() => r'f9f087885b711a7a8a5289a1d4c2cdeccd46f099';

abstract class _$MyVouchers extends $Notifier<List<VoucherModel>> {
  List<VoucherModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<VoucherModel>, List<VoucherModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<VoucherModel>, List<VoucherModel>>,
              List<VoucherModel>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
