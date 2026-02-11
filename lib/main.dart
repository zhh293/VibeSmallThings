import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/core/config/router.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: GeekToolboxApp()));
}

class GeekToolboxApp extends StatelessWidget {
  const GeekToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Geek Toolbox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
