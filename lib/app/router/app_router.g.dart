// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $appShellRoute,
  $playerRoute,
  $qrLoginRoute,
  $profileRoute,
  $recentRoute,
  $settingsRoute,
];

RouteBase get $appShellRoute => StatefulShellRouteData.$route(
  navigatorContainerBuilder: AppShellRoute.$navigatorContainerBuilder,
  factory: $AppShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/',
          hasOverriddenOnExit: false,
          factory: $HomeRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'playlist/:playlistId',
              hasOverriddenOnExit: false,
              factory: $HomePlaylistRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/search',
          hasOverriddenOnExit: false,
          factory: $SearchRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'playlist/:playlistId',
              hasOverriddenOnExit: false,
              factory: $SearchPlaylistRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/my',
          hasOverriddenOnExit: false,
          factory: $MyRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'playlist/:playlistId',
              hasOverriddenOnExit: false,
              factory: $MyPlaylistRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $AppShellRouteExtension on AppShellRoute {
  static AppShellRoute _fromState(GoRouterState state) => const AppShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) =>
      HomeRoute(fixture: state.uri.queryParameters['fixture']);

  HomeRoute get _self => this as HomeRoute;

  @override
  String get location => GoRouteData.$location(
    '/',
    queryParams: {if (_self.fixture != null) 'fixture': _self.fixture},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HomePlaylistRoute on GoRouteData {
  static HomePlaylistRoute _fromState(GoRouterState state) =>
      HomePlaylistRoute(playlistId: state.pathParameters['playlistId']!);

  HomePlaylistRoute get _self => this as HomePlaylistRoute;

  @override
  String get location => GoRouteData.$location(
    '/playlist/${Uri.encodeComponent(_self.playlistId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) =>
      SearchRoute(fixture: state.uri.queryParameters['fixture']);

  SearchRoute get _self => this as SearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/search',
    queryParams: {if (_self.fixture != null) 'fixture': _self.fixture},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchPlaylistRoute on GoRouteData {
  static SearchPlaylistRoute _fromState(GoRouterState state) =>
      SearchPlaylistRoute(playlistId: state.pathParameters['playlistId']!);

  SearchPlaylistRoute get _self => this as SearchPlaylistRoute;

  @override
  String get location => GoRouteData.$location(
    '/search/playlist/${Uri.encodeComponent(_self.playlistId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MyRoute on GoRouteData {
  static MyRoute _fromState(GoRouterState state) =>
      MyRoute(fixture: state.uri.queryParameters['fixture']);

  MyRoute get _self => this as MyRoute;

  @override
  String get location => GoRouteData.$location(
    '/my',
    queryParams: {if (_self.fixture != null) 'fixture': _self.fixture},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MyPlaylistRoute on GoRouteData {
  static MyPlaylistRoute _fromState(GoRouterState state) =>
      MyPlaylistRoute(playlistId: state.pathParameters['playlistId']!);

  MyPlaylistRoute get _self => this as MyPlaylistRoute;

  @override
  String get location => GoRouteData.$location(
    '/my/playlist/${Uri.encodeComponent(_self.playlistId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $playerRoute => GoRouteData.$route(
  path: '/player',
  hasOverriddenOnExit: false,
  factory: $PlayerRoute._fromState,
);

mixin $PlayerRoute on GoRouteData {
  static PlayerRoute _fromState(GoRouterState state) => const PlayerRoute();

  @override
  String get location => GoRouteData.$location('/player');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $qrLoginRoute => GoRouteData.$route(
  path: '/login/qr',
  hasOverriddenOnExit: false,
  factory: $QrLoginRoute._fromState,
);

mixin $QrLoginRoute on GoRouteData {
  static QrLoginRoute _fromState(GoRouterState state) => const QrLoginRoute();

  @override
  String get location => GoRouteData.$location('/login/qr');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileRoute => GoRouteData.$route(
  path: '/profile',
  hasOverriddenOnExit: false,
  factory: $ProfileRoute._fromState,
);

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $recentRoute => GoRouteData.$route(
  path: '/recent',
  hasOverriddenOnExit: false,
  factory: $RecentRoute._fromState,
);

mixin $RecentRoute on GoRouteData {
  static RecentRoute _fromState(GoRouterState state) => const RecentRoute();

  @override
  String get location => GoRouteData.$location('/recent');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  hasOverriddenOnExit: false,
  factory: $SettingsRoute._fromState,
);

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
