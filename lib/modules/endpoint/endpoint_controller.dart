import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_store.dart';

part 'endpoint_controller.g.dart';

final endpointStoreProvider = Provider<EndpointStore>((ref) => EndpointStore());

@Riverpod(keepAlive: true)
class BackendEndpointController extends _$BackendEndpointController {
  @override
  Future<BackendEndpoint> build() {
    return ref.watch(endpointStoreProvider).read();
  }

  Future<void> save(String rawEndpoint) async {
    final endpoint = BackendEndpoint.parse(rawEndpoint);
    await ref.read(endpointStoreProvider).save(endpoint);
    state = AsyncData(endpoint);
  }

  Future<EndpointProbeResult> probe(String rawEndpoint) {
    final endpoint = BackendEndpoint.parse(rawEndpoint);
    return ref.read(endpointStoreProvider).probe(endpoint);
  }

  Future<void> restoreDefault() async {
    await ref.read(endpointStoreProvider).restoreDefault();
    state = AsyncData(BackendEndpoint.defaultValue);
  }
}
