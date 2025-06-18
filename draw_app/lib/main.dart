import 'package:flutter/material.dart';
import 'page0_title.dart';
import 'page1_home.dart';
import 'page2_draw.dart';
import 'page3_share.dart';
import 'page4_condition.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

/*
  最新のFlutterに対応するため、動画と少しコードが変わりました
*/

main() {
  final app = App();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (_) => ProviderScope(child: app),
    ),
  );
}

// アプリ全体
class App extends StatelessWidget {
  App({super.key});

  final router = GoRouter(
    // パス (アプリが起動したとき)
    initialLocation: '/title',
    // パスと画面の組み合わせ
    routes: [
      GoRoute(path: '/title', builder: (context, state) =>PageTitle()),
      GoRoute(path: '/a', builder: (context, state) => PageA()),
      GoRoute(path: '/b', builder: (context, state) => PageB()),
      GoRoute(path: '/c', builder: (context, state) => PageC()),
      GoRoute(path: '/d', builder: (context, state) => PageD()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
