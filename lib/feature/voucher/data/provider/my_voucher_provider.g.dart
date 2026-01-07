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
    extends $AsyncNotifierProvider<MyVouchers, List<VoucherModel>> {
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
}

String _$myVouchersHash() => r'7e49d112f2ecfa1907c994470e12e3891068b594';

abstract class _$MyVouchers extends $AsyncNotifier<List<VoucherModel>> {
  FutureOr<List<VoucherModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<VoucherModel>>, List<VoucherModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<VoucherModel>>, List<VoucherModel>>,
              AsyncValue<List<VoucherModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
