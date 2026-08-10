import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/layouts/app_drawer.dart';
import 'package:scopify_mobile/layouts/mini_player.dart';

class AppShellLayout extends StatelessWidget {
  const AppShellLayout({
    required this.navigationShell,
    required this.branchNavigators,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> branchNavigators;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final allowsDrawer =
        currentPath == '/' || currentPath == '/search' || currentPath == '/my';

    return Scaffold(
      backgroundColor: AppTokens.surfaceBase,
      drawer: allowsDrawer ? const AppDrawer() : null,
      drawerEnableOpenDragGesture: allowsDrawer,
      drawerEdgeDragWidth: allowsDrawer ? 32 : null,
      body: IndexedStack(
        index: navigationShell.currentIndex,
        children: branchNavigators,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: '搜索',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: '我的',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
