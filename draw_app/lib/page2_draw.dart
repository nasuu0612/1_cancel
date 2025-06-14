import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; //モバイルのファイル用
import 'package:camera/camera.dart'; //XFile用
import 'camera_utils/camera_handler.dart'; //CameraHandlerをインポート

//
// 画面 B
//
class PageB extends StatelessWidget {
  const PageB({super.key});

  // 進むボタンを押したとき
  push(BuildContext context) {
    // 画面 C へ進む
    context.push('/c');
  }

  // 戻るボタンを押したとき
  back(BuildContext context) {
    // 前の画面 へ戻る
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    // 画面の上に表示するバー
    final appBar = AppBar(
      backgroundColor: Colors.green,
      title: const Text('Draw'),
    );

    // 進むボタン
    final goButton = ElevatedButton(
      onPressed: () => push(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text('完了'),
    );

    // 戻るボタン
    final backButton = ElevatedButton(
      onPressed: () => back(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('< 戻る'),
    );

    // 画面全体
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  backButton,
                  const SizedBox(width: 70), // ボタンの間のスペース
                  goButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
