import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/pages/home/home_fixture.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'home_content_provider.g.dart';

@riverpod
AsyncValue<HomeFixture> homeContent(Ref ref, FixtureMode mode) {
  return switch (mode) {
    FixtureMode.loading => const AsyncLoading<HomeFixture>(),
    FixtureMode.data => AsyncData<HomeFixture>(homeFixture),
    FixtureMode.empty => const AsyncData<HomeFixture>(
      HomeFixture(shortcuts: <Never>[], recommendations: <Never>[]),
    ),
    FixtureMode.error => AsyncError<HomeFixture>(
      StateError('Home fixture failure'),
      StackTrace.empty,
    ),
  };
}
