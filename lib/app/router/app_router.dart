import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/layouts/app_shell_layout.dart';
import 'package:scopify_mobile/pages/home/home_page.dart';
import 'package:scopify_mobile/pages/my/my_page.dart';
import 'package:scopify_mobile/pages/player/player_page.dart';
import 'package:scopify_mobile/pages/playlist/playlist_detail_page.dart';
import 'package:scopify_mobile/pages/playlist/recent_page.dart';
import 'package:scopify_mobile/pages/profile/profile_page.dart';
import 'package:scopify_mobile/pages/search/search_page.dart';
import 'package:scopify_mobile/pages/settings/settings_page.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'app_router.g.dart';

GoRouter createAppRouter({String initialLocation = '/'}) =>
    GoRouter(routes: $appRoutes, initialLocation: initialLocation);

final GoRouter appRouter = createAppRouter();

@TypedStatefulShellRoute<AppShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeShellBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(
          path: '/',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<HomePlaylistRoute>(path: 'playlist/:playlistId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<SearchShellBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SearchRoute>(
          path: '/search',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<SearchPlaylistRoute>(path: 'playlist/:playlistId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<MyShellBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MyRoute>(
          path: '/my',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<MyPlaylistRoute>(path: 'playlist/:playlistId'),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return navigationShell;
  }

  static Widget $navigatorContainerBuilder(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  ) {
    return AppShellLayout(
      navigationShell: navigationShell,
      branchNavigators: children,
    );
  }
}

class HomeShellBranch extends StatefulShellBranchData {
  const HomeShellBranch();
}

class SearchShellBranch extends StatefulShellBranchData {
  const SearchShellBranch();
}

class MyShellBranch extends StatefulShellBranchData {
  const MyShellBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute({this.fixture});

  final String? fixture;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HomePage(fixtureMode: FixtureMode.fromQuery(fixture));
  }
}

class HomePlaylistRoute extends GoRouteData with $HomePlaylistRoute {
  const HomePlaylistRoute({required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PlaylistDetailPage(playlistId: playlistId);
  }
}

class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute({this.fixture});

  final String? fixture;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchPage(fixtureMode: FixtureMode.fromQuery(fixture));
  }
}

class SearchPlaylistRoute extends GoRouteData with $SearchPlaylistRoute {
  const SearchPlaylistRoute({required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PlaylistDetailPage(playlistId: playlistId);
  }
}

class MyRoute extends GoRouteData with $MyRoute {
  const MyRoute({this.fixture, this.guest = true});

  final String? fixture;
  final bool guest;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MyPage(fixtureMode: FixtureMode.fromQuery(fixture), guest: guest);
  }
}

class MyPlaylistRoute extends GoRouteData with $MyPlaylistRoute {
  const MyPlaylistRoute({required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PlaylistDetailPage(playlistId: playlistId);
  }
}

@TypedGoRoute<PlayerRoute>(path: '/player')
class PlayerRoute extends GoRouteData with $PlayerRoute {
  const PlayerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PlayerPage();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfilePage();
}

@TypedGoRoute<RecentRoute>(path: '/recent')
class RecentRoute extends GoRouteData with $RecentRoute {
  const RecentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const RecentPage();
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}
