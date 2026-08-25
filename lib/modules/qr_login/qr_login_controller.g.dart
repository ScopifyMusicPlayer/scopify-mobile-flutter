// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QrLoginController)
final qrLoginControllerProvider = QrLoginControllerProvider._();

final class QrLoginControllerProvider
    extends $NotifierProvider<QrLoginController, QrLoginState> {
  QrLoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'qrLoginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$qrLoginControllerHash();

  @$internal
  @override
  QrLoginController create() => QrLoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QrLoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QrLoginState>(value),
    );
  }
}

String _$qrLoginControllerHash() => r'2cc64ab4cfb39b3c6e1d9e60578624778551d157';

abstract class _$QrLoginController extends $Notifier<QrLoginState> {
  QrLoginState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<QrLoginState, QrLoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QrLoginState, QrLoginState>,
              QrLoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
