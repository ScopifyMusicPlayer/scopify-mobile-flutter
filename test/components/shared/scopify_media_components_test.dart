import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/theme/app_theme.dart';
import 'package:scopify_mobile/components/shared/scopify_media_card.dart';
import 'package:scopify_mobile/components/shared/scopify_media_list_tile.dart';

void main() {
  testWidgets('media card keeps Web-style image-first hierarchy', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SizedBox(
            width: 180,
            child: ScopifyMediaCard(
              title: '今日私藏',
              subtitle: '为你推荐',
              artworkSeed: 'today',
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('今日私藏'), findsOneWidget);
    expect(find.text('为你推荐'), findsOneWidget);
    await tester.tap(find.text('今日私藏'));
    expect(taps, 1);
  });

  testWidgets('media list tile exposes active title and trailing action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: ScopifyMediaListTile(
            title: 'Dissolve',
            subtitle: 'Absofacto · 刚刚播放',
            artworkSeed: 'dissolve',
            isActive: true,
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ),
    );

    expect(find.text('Dissolve'), findsOneWidget);
    expect(find.text('Absofacto · 刚刚播放'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });
}
