import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geek_toolbox/features/dashboard/dashboard_screen.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/code_to_video_screen.dart';
import 'package:geek_toolbox/features/mesh_messenger/presentation/mesh_messenger_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/code-to-video',
      builder: (context, state) => const CodeToVideoScreen(),
    ),
    GoRoute(
      path: '/mesh-messenger',
      builder: (context, state) => const MeshMessengerScreen(),
    ),
  ],
);
