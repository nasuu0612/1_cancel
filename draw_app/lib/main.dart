import 'package:flutter/material.dart';
import 'page0_title.dart';
import 'page1_home.dart';
import 'page2_draw.dart';
import 'page3_share.dart';
import 'package:go_router/go_router.dart';

/*
  最新のFlutterに対応するため、動画と少しコードが変わりました
*/
main() {
  final app = App();
  runApp(app);
}

// アプリ全体
class App extends StatelessWidget {
  App({super.key});

  final router = GoRouter(
    // パス (アプリが起動したとき)
    initialLocation: '/title',
    // パスと画面の組み合わせ
    routes: [
      GoRoute(path: '/title', builder: (context, state) => const PageTitle()),
      GoRoute(path: '/a', builder: (context, state) => const PageA()),
      //GoRoute(path: '/b', builder: (context, state) => const PageB()),
      GoRoute(path: '/b', builder: (context, state) => const Page2Draw()),
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
