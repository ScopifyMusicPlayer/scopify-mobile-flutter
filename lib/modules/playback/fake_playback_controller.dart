import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';

part 'fake_playback_controller.g.dart';

class FakePlaybackState {
  const FakePlaybackState({
    this.currentTrack,
    this.isPlaying = false,
    this.showsLyrics = false,
  });

  final MediaTrack? currentTrack;
  final bool isPlaying;
  final bool showsLyrics;

  bool get hasTrack => currentTrack != null;

  FakePlaybackState copyWith({
    MediaTrack? currentTrack,
    bool? isPlaying,
    bool? showsLyrics,
  }) {
    return FakePlaybackState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      showsLyrics: showsLyrics ?? this.showsLyrics,
    );
  }
}

@Riverpod(keepAlive: true)
class FakePlayback extends _$FakePlayback {
  @override
  FakePlaybackState build() => const FakePlaybackState();

  void play(MediaTrack track) {
    state = state.copyWith(currentTrack: track, isPlaying: true);
  }

  void toggle(MediaTrack fallbackTrack) {
    state = state.copyWith(
      currentTrack: state.currentTrack ?? fallbackTrack,
      isPlaying: !state.isPlaying,
    );
  }

  void toggleLyrics() {
    state = state.copyWith(showsLyrics: !state.showsLyrics);
  }
}
