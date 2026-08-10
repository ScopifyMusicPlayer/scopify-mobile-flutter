// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'endpoint_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BackendEndpointController)
final backendEndpointControllerProvider = BackendEndpointControllerProvider._();

final class BackendEndpointControllerProvider
    extends $AsyncNotifierProvider<BackendEndpointController, BackendEndpoint> {
  BackendEndpointControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendEndpointControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendEndpointControllerHash();

  @$internal
  @override
  BackendEndpointController create() => BackendEndpointController();
}

String _$backendEndpointControllerHash() =>
    r'cf48acceb2f097c2d7f63dd4d254206e892a0e8b';

abstract class _$BackendEndpointController
    extends $AsyncNotifier<BackendEndpoint> {
  FutureOr<BackendEndpoint> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BackendEndpoint>, BackendEndpoint>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BackendEndpoint>, BackendEndpoint>,
              AsyncValue<BackendEndpoint>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
