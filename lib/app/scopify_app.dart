import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_theme.dart';

class ScopifyApp extends StatelessWidget {
  const ScopifyApp({this.router, super.key});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router ?? appRouter,
      theme: AppTheme.dark(),
      title: 'Scopify',
    );
  }
}
