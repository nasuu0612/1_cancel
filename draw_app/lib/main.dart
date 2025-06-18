import 'package:flutter/material.dart';
import 'page0_title.dart';
import 'page1_home.dart';
import 'page2_draw.dart';
import 'page2-1_select.dart';
import 'page2-2_edit.dart';
import 'page3_share.dart';
import 'page4_condition.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'dart:io';

/*
  最新のFlutterに対応するため、動画と少しコードが変わりました
*/

main() {
  final app = App();
  runApp(
    DevicePreview(enabled: true, builder: (_) => ProviderScope(child: app)),
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
      GoRoute(path: '/title', builder: (context, state) => const PageTitle()),
      GoRoute(path: '/a', builder: (context, state) => const PageA()),
      //GoRoute(path: '/b', builder: (context, state) => const PageB()),
      GoRoute(path: '/b', builder: (context, state) => const Page2Draw()),
      GoRoute(path: '/b1', builder: (context, state) => const Page2Select()),
      GoRoute(
        path: '/b2',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return Page2Edit(
            underImageFile: args?['underImageFile'],
            upperImageBytes: args?['upperImageBytes'],
          );
        },
      ),
      //必要なデータが未生成の場合はextraを使う
      GoRoute(
        path: '/c',
        builder: (context, state) {
          //画像ファイルをextraで受け取る
          final file = state.extra as File?;
          return PageC(editedImageFile: file);
        },
      ),
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
