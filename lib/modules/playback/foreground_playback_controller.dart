import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/playback/lyric_document.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/modules/playback/playback_api.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

part 'foreground_playback_controller.g.dart';

enum PlaybackRepeatMode { off, all, one }

class PlaybackFailure {
  const PlaybackFailure({required this.message, required this.track});

  final String message;
  final MediaTrack track;
}

class ForegroundPlaybackState {
  const ForegroundPlaybackState({
    this.queue = const <MediaTrack>[],
    this.currentIndex = -1,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.showsLyrics = false,
    this.lyrics,
    this.repeatMode = PlaybackRepeatMode.off,
    this.shuffleEnabled = false,
    this.failure,
  });

  final List<MediaTrack> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final bool showsLyrics;
  final LyricDocument? lyrics;
  final PlaybackRepeatMode repeatMode;
  final bool shuffleEnabled;
  final PlaybackFailure? failure;

  MediaTrack? get currentTrack =>
      currentIndex >= 0 && currentIndex < queue.length
      ? queue[currentIndex]
      : null;

  bool get hasTrack => currentTrack != null;

  ForegroundPlaybackState copyWith({
    List<MediaTrack>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    bool? showsLyrics,
    LyricDocument? lyrics,
    PlaybackRepeatMode? repeatMode,
    bool? shuffleEnabled,
    PlaybackFailure? failure,
    bool clearLyrics = false,
    bool clearFailure = false,
  }) {
    return ForegroundPlaybackState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      showsLyrics: showsLyrics ?? this.showsLyrics,
      lyrics: clearLyrics ? null : lyrics ?? this.lyrics,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

@Riverpod(keepAlive: true)
class ForegroundPlayback extends _$ForegroundPlayback {
  audio.AudioPlayer? _player;
  StreamSubscription<audio.PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Object>? _eventErrorSubscription;
  final List<int> _shuffleHistory = <int>[];
  final Random _random = Random();
  bool _isRecovering = false;

  @override
  ForegroundPlaybackState build() {
    ref.onDispose(_disposePlayer);
    return const ForegroundPlaybackState();
  }

  Future<void> playQueue(List<MediaTrack> queue, {int startIndex = 0}) async {
    if (queue.isEmpty) return;
    final index = startIndex.clamp(0, queue.length - 1);
    _shuffleHistory
      ..clear()
      ..add(index);
    state = ForegroundPlaybackState(
      queue: List<MediaTrack>.unmodifiable(queue),
      currentIndex: index,
      isLoading: true,
      repeatMode: state.repeatMode,
      shuffleEnabled: state.shuffleEnabled,
      showsLyrics: state.showsLyrics,
    );
    await _loadCurrentAndPlay();
  }

  Future<void> toggle(MediaTrack fallbackTrack) async {
    if (!state.hasTrack) {
      await playQueue(<MediaTrack>[fallbackTrack]);
      return;
    }
    final track = state.currentTrack!;
    if (_isFixtureTrack(track)) {
      state = state.copyWith(isPlaying: !state.isPlaying);
      return;
    }
    final player = _player;
    if (player == null) {
      await _loadCurrentAndPlay();
      return;
    }
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> seek(Duration position) async {
    if (_isFixtureTrack(state.currentTrack)) {
      state = state.copyWith(position: position);
      return;
    }
    await _player?.seek(position);
  }

  Future<void> next() async {
    final nextIndex = _nextIndex();
    if (nextIndex == null) {
      state = state.copyWith(isPlaying: false, isLoading: false);
      return;
    }
    _shuffleHistory.add(nextIndex);
    state = state.copyWith(
      currentIndex: nextIndex,
      isLoading: true,
      position: Duration.zero,
      duration: Duration.zero,
      clearLyrics: true,
      clearFailure: true,
    );
    await _loadCurrentAndPlay();
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    final previousIndex = state.shuffleEnabled && _shuffleHistory.length > 1
        ? _shuffleHistory[_shuffleHistory.length - 2]
        : (state.currentIndex > 0 ? state.currentIndex - 1 : 0);
    if (state.shuffleEnabled && _shuffleHistory.length > 1) {
      _shuffleHistory.removeLast();
    }
    state = state.copyWith(
      currentIndex: previousIndex,
      isLoading: true,
      position: Duration.zero,
      duration: Duration.zero,
      clearLyrics: true,
      clearFailure: true,
    );
    await _loadCurrentAndPlay();
  }

  void toggleLyrics() {
    state = state.copyWith(showsLyrics: !state.showsLyrics);
  }

  void toggleShuffle() {
    state = state.copyWith(shuffleEnabled: !state.shuffleEnabled);
  }

  void cycleRepeatMode() {
    final mode = switch (state.repeatMode) {
      PlaybackRepeatMode.off => PlaybackRepeatMode.all,
      PlaybackRepeatMode.all => PlaybackRepeatMode.one,
      PlaybackRepeatMode.one => PlaybackRepeatMode.off,
    };
    state = state.copyWith(repeatMode: mode);
  }

  Future<void> _loadCurrentAndPlay() async {
    final track = state.currentTrack;
    if (track == null) return;
    if (_isFixtureTrack(track)) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
        position: Duration.zero,
        duration: track.duration,
        lyrics: LyricDocument.fixture,
        clearFailure: true,
      );
      return;
    }

    try {
      final endpoint = await ref.read(backendEndpointControllerProvider.future);
      final lyricFuture = _loadLyrics(endpoint.id, track.id);
      final source = await ref
          .read(playbackApiProvider)
          .resolveAudioUrl(track.id);
      final player = await _ensurePlayer();
      await player.setUrl(source.url);
      if (state.currentTrack?.id != track.id) return;
      state = state.copyWith(
        isLoading: false,
        position: Duration.zero,
        duration: player.duration ?? track.duration,
        clearFailure: true,
      );
      await player.play();
      final lyrics = await lyricFuture;
      if (state.currentTrack?.id == track.id && lyrics != null) {
        state = state.copyWith(lyrics: lyrics);
      }
    } on AppFailure catch (failure) {
      await _recoverFromFailure(failure.message, track);
    } on Object {
      await _recoverFromFailure('歌曲暂时无法播放，正在尝试下一首。', track);
    }
  }

  Future<LyricDocument?> _loadLyrics(String endpointId, String trackId) async {
    final key = QueryCacheKey(
      endpointId: endpointId,
      accountId: 'public',
      scope: 'public',
      query: 'playback.lyrics',
      parameters: <String, Object?>{'trackId': trackId},
      schemaVersion: 1,
    );
    final cache = ref.read(queryCacheStoreProvider);
    final cached = await cache.read(key);
    if (cached != null) return LyricDocument.fromJson(cached.payload);
    try {
      final lyrics = await ref.read(playbackApiProvider).fetchLyrics(trackId);
      await cache.write(
        key: key,
        payload: lyrics.toJson(),
        policy: const QueryCachePolicy(
          freshFor: Duration(hours: 24),
          maxAge: Duration(days: 30),
        ),
      );
      return lyrics;
    } on Object {
      return null;
    }
  }

  Future<audio.AudioPlayer> _ensurePlayer() async {
    final existing = _player;
    if (existing != null) return existing;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    final player = audio.AudioPlayer();
    _player = player;
    _playerStateSubscription = player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading:
            playerState.processingState == audio.ProcessingState.loading ||
            playerState.processingState == audio.ProcessingState.buffering,
      );
      if (playerState.processingState == audio.ProcessingState.completed) {
        unawaited(_onTrackCompleted());
      }
    });
    _positionSubscription = player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    _durationSubscription = player.durationStream.listen((duration) {
      if (duration != null) state = state.copyWith(duration: duration);
    });
    _eventErrorSubscription = player.playbackEventStream.listen(
      (_) {},
      onError: (_, _) {
        final track = state.currentTrack;
        if (track != null) {
          unawaited(_recoverFromFailure('歌曲播放中断，正在尝试下一首。', track));
        }
      },
    );
    return player;
  }

  Future<void> _onTrackCompleted() async {
    if (state.repeatMode == PlaybackRepeatMode.one) {
      await _loadCurrentAndPlay();
      return;
    }
    await next();
  }

  Future<void> _recoverFromFailure(String message, MediaTrack track) async {
    if (_isRecovering) return;
    _isRecovering = true;
    state = state.copyWith(
      isLoading: false,
      isPlaying: false,
      failure: PlaybackFailure(message: message, track: track),
    );
    try {
      if (state.queue.length > 1) await next();
    } finally {
      _isRecovering = false;
    }
  }

  int? _nextIndex() {
    if (state.queue.isEmpty) return null;
    if (state.shuffleEnabled && state.queue.length > 1) {
      var next = state.currentIndex;
      while (next == state.currentIndex) {
        next = _random.nextInt(state.queue.length);
      }
      return next;
    }
    if (state.currentIndex < state.queue.length - 1) {
      return state.currentIndex + 1;
    }
    return state.repeatMode == PlaybackRepeatMode.all ? 0 : null;
  }

  bool _isFixtureTrack(MediaTrack? track) =>
      track == null || int.tryParse(track.id) == null;

  void _disposePlayer() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _eventErrorSubscription?.cancel();
    _player?.dispose();
  }
}
