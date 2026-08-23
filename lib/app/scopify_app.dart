import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/session_expired_gate.dart';
import 'package:scopify_mobile/app/theme/app_theme.dart';

class ScopifyApp extends StatelessWidget {
  const ScopifyApp({this.router, super.key});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    final activeRouter = router ?? appRouter;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: activeRouter,
      theme: AppTheme.dark(),
      title: 'Scopify',
      builder: (context, child) => SessionExpiredGate(
        onRelogin: () => activeRouter.push(const QrLoginRoute().location),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
