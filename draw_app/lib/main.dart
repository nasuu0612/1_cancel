import 'package:flutter/material.dart';
import 'page1_home.dart';
import 'page2_draw.dart';
import 'page3_share.dart';
import 'package:go_router/go_router.dart';

void main() {
  final app = App();
  runApp(app);
}

class App extends StatelessWidget {
  App({super.key});

  final router = GoRouter(
    // パス (アプリが起動したとき)
    initialLocation: '/a',
    // パスと画面の組み合わせ
    routes: [
      GoRoute(path: '/a', builder: (context, state) => const PageA()),
      GoRoute(path: '/b', builder: (context, state) => const PageB()),
      GoRoute(path: '/c', builder: (context, state) => const PageC()),
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
