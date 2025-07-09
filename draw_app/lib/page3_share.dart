import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class PageC extends StatelessWidget {
  final File? editedImageFile;

  const PageC({Key? key, this.editedImageFile}) : super(key: key);

  push(BuildContext context) {
    context.push('/a');
  }

  // ギャラリーへ画像保存
  Future<void> saveImageToGallery(BuildContext context) async {
    if (editedImageFile == null) return;

    try {
      // パーミッション要求（iOS/Android）
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("保存の権限がありません")));
          return;
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photosAddOnly.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("写真のアクセスが拒否されました")));
          return;
        }
      }

      final Uint8List bytes = await editedImageFile!.readAsBytes();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: "nuri_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("写真アプリに保存しました！")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("保存に失敗しました")));
      }
    } catch (e) {
      debugPrint("保存エラー: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("保存に失敗しました")));
    }
  }

  // シェア機能
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

    // 画面の上に表示するバー
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
      onPressed: () => saveImageToGallery(context),
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
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("完成！",
              ),
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
