import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
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
      //パーミッションはGalを使う場合は不要らしいです(Androidでは確認しています)
      // パーミッション要求（iOS/Android）
      /*if (Platform.isAndroid) {
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
      }*/

      // 新しいファイル名で一時ファイルを作成
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now();
      
      //ファイル名フォーマット(変更可)
      final formattedDate = '${timestamp.year}年${timestamp.month.toString().padLeft(2, '0')}月${timestamp.day.toString().padLeft(2, '0')}日_${timestamp.hour.toString().padLeft(2, '0')}時${timestamp.minute.toString().padLeft(2, '0')}分';
      final newFileName = '保存されたもの_$formattedDate.png';
      
      final newFile = File('${dir.path}/$newFileName');
      
      // 元のファイルを新しい名前でコピー
      await editedImageFile!.copy(newFile.path);
      
      // 新しいファイル名でギャラリーに保存
      await Gal.putImage(newFile.path);

      if(!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("保存しました"))
      );
      
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
