import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PageC extends StatelessWidget {
  final File? editedImageFile;

  const PageC({Key? key, this.editedImageFile}) : super(key: key);

  push(BuildContext context) {
    context.push('/a');
  }

  // 画像を保存する関数
  Future<void> saveImage(BuildContext context) async {
    if (editedImageFile == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory(); // 端末の保存先
      final newPath = '${directory.path}/nuri_image.png'; // 保存先ファイル名
      final newFile = await editedImageFile!.copy(newPath);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("保存しました: ${newFile.path}")));
    } catch (e) {
      debugPrint("保存エラー: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("保存に失敗しました")));
    }
  }

  // シェア機能（SNS共有など）
  Future<void> shareImage(BuildContext context) async {
    if (editedImageFile == null) return;

    try {
      await Share.shareXFiles([
        XFile(editedImageFile!.path),
      ], text: '私の塗り絵作品を見てね！');
    } catch (e) {
      debugPrint("シェアエラー: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("シェアに失敗しました")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.blue,
      title: const Text('Share'),
    );

    final shareButton = ElevatedButton(
      onPressed: () => shareImage(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text('シェア'),
    );

    final saveButton = ElevatedButton(
      onPressed: () => saveImage(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text('保存'),
    );

    final homeButton = ElevatedButton(
      onPressed: () => push(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      child: const Text('ホームへ'),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          if (editedImageFile != null)
            Center(child: Image.file(editedImageFile!)),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text("完成！"),
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
                  const SizedBox(width: 10),
                  saveButton,
                  const SizedBox(width: 10),
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
