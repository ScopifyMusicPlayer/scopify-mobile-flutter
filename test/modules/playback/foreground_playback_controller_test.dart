import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/playback/foreground_playback_controller.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

void main() {
  test(
    'fixture queue supports next and list repeat without platform audio',
    () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);
      final controller = container.read(foregroundPlaybackProvider.notifier);
      final queue = playlistFixtures.first.tracks;

      await controller.playQueue(queue);
      expect(
        container.read(foregroundPlaybackProvider).currentTrack,
        queue.first,
      );
      expect(container.read(foregroundPlaybackProvider).isPlaying, isTrue);

      await controller.next();
      expect(container.read(foregroundPlaybackProvider).currentTrack, queue[1]);

      controller.cycleRepeatMode();
      await controller.next();
      await controller.next();
      expect(
        container.read(foregroundPlaybackProvider).currentTrack,
        queue.first,
      );
    },
  );
}
