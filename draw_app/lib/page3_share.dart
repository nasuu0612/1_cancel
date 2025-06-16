import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//
// 画面 C
//
class PageC extends StatelessWidget {
  final File? editedImageFile;

  const PageC({Key? key, this.editedImageFile}) : super(key: key);

  push(BuildContext context) {
    // 画面 a へ進む
    context.push('/a');
  }

  @override
  Widget build(BuildContext context) {
    // 画面の上に表示するバー
    final appBar = AppBar(
      backgroundColor: Colors.blue,
      title: const Text('Share'),
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
          if (editedImageFile != null)
            Center(child: Image.file(editedImageFile!)),
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
