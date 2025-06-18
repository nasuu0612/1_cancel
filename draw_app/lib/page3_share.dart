import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//
// 画面 C
//
class PageC extends StatelessWidget {
  const PageC({super.key});

  push(BuildContext context) {
    // 画面 a へ進む
    context.push('/a');
  }

  @override
  Widget build(BuildContext context) {
    //画面のサイズ取得
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 画面の上に表示するバー
    final appBar = AppBar(
      backgroundColor: Colors.blue,
      title: const Text('Share'),
    );

    // 画像領域
    final image = Container(
      color: Colors.grey,
      width: screenWidth * 0.8,
      height: screenHeight * 0.5,
      //child: const Text("画像"),
    );

    final shareButton = ElevatedButton(
      onPressed: () => push(context),
      // MEMO: primary は古くなったので backgroundColor へ変更しました
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text('シェア'),
    );

    final saveButton = ElevatedButton(
      onPressed: () => push(context),
      // MEMO: primary は古くなったので backgroundColor へ変更しました
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text('保存'),
    );

    // 戻るボタン
    final homeButton = ElevatedButton(
      onPressed: () => push(context),
      // MEMO: primary は古くなったので backgroundColor へ変更しました
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      child: const Text('ホームへ'),
    );

    // 画面全体
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("完成！",
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: image,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  shareButton,
                  const SizedBox(width: 10), // ボタンの間のスペース
                  saveButton,
                  const SizedBox(width: 10), // ボタンの間のスペース
                  homeButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
