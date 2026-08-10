import 'package:flutter/widgets.dart';
import 'package:scopify_mobile/pages/playlist/playlist_detail_page.dart';

class RecentPage extends StatelessWidget {
  const RecentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaylistDetailPage(
      playlistId: 'daily-mix',
      eyebrow: '最近播放',
      titleOverride: '最近播放',
    );
  }
}
