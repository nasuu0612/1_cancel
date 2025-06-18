import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'camera_utils/camera_handler.dart'; //CameraHandlerをインポート
import 'package:camera/camera.dart'; //XFile用
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; //モバイルのファイル用

class Page2Draw extends StatefulWidget {
  const Page2Draw({Key? key}) : super(key: key);

  @override
  State<Page2Draw> createState() => _Page2DrawState();
}

class _Page2DrawState extends State<Page2Draw> {
  final CameraHandler _cameraHandler = CameraHandler();
  XFile? _imageFile; //キャプチャした画像を保存する変数
  bool _showCameraPreview = false;
  Uint8List? _upperImageBytes; // ダミーで読み込むマスク画像

  @override
  void initState() {
    super.initState();
    _loadDummyMask();
  }

  Future<void> _loadDummyMask() async {
    // assets/images/mask.png を読み込む
    final bytes = await rootBundle.load('assets/images/mask.png');
    setState(() {
      _upperImageBytes = bytes.buffer.asUint8List();
    });
  }

  @override
  void dispose() {
    _cameraHandler.dispose(); //カメラのリソースを解放
    super.dispose();
  }

  //完了ボタンのアクション(元のファイルのpushメソッドの部分)
  void _completeAndProceed() {
    if (_imageFile != null && _upperImageBytes != null) {
      // カメラ画像（downer）とマスク画像（upper）をpageT_editに渡す
      context.push('/t', extra: {
        'underImageFile': File(_imageFile!.path),
        'upperImageBytes': _upperImageBytes,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('写真またはマスク画像がありません')),
      );
    }
  }

  //戻るボタンのアクション(元のBackメソッドの部分)
  void _goBack() {
    if (_showCameraPreview) {
      //カメラプレビュー表示中の場合はプレビューを閉じる
      setState(() {
        _showCameraPreview = false;
        //_imageFileはクリアせずに保持している状態
        //プレビューキャンセルで画像は破棄する場合は
        //_imageFile = null;
      });
    } else {
      //それ以外の場合は前の画面に戻る
      context.pop();
    }
  }

  Future<void> _startCamera() async {
    if (!_cameraHandler.isCameraInitialized) {
      await _cameraHandler.initializeCamera();
    }

    if (_cameraHandler.isCameraInitialized && mounted) {
      setState(() {
        _showCameraPreview = true; //カメラプレビューを表示する状態
        _imageFile = null; //以前の画像はクリア
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カメラを起動できない状態です')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraHandler.isCameraInitialized || _cameraHandler.controller == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カメラが準備できていません')),
        );
      }
      return;
    }

    final XFile? picture = await _cameraHandler.takePicture();

    if (picture != null) {
      if (!mounted) return;
      setState(() {
        _imageFile = picture; //撮影した写真を保存
        _showCameraPreview = false; //カメラプレビューを非表示にする
        _cameraHandler.dispose(); //カメラのリソースを解放する
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('写真の撮影に失敗しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.green, //アプリバーの背景色
      title: const Text('Draw'), //アプリバーのタイトル
    );

    Widget mainContent;
    if (_showCameraPreview) {
      if (_cameraHandler.isCameraInitialized && _cameraHandler.controller != null) {
        mainContent = Center(
          child: AspectRatio(
            aspectRatio: 3 / 4, //カメラプレビューのアスペクト比
            child: CameraPreviewWidget(cameraHandler: _cameraHandler),
          ),
        );
      } else {
        //カメラ初期化中or失敗
        mainContent = const Center(child: CircularProgressIndicator());
      }
    } else if (_imageFile != null) {
      mainContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.file(File(_imageFile!.path)), //撮影した画像を表示
        ),
      );
    } else {
      mainContent = const Center(
        child: Text('「カメラ起動」ボタンを押して撮影してください'),
      );
    }

    List<Widget> actionButtons = [];
    if (_showCameraPreview) {
      actionButtons = [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showCameraPreview = false; //カメラプレビューを閉じる
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('キャンセル'),
         ),
         const SizedBox(width: 20), //ボタン間のスペース

         ElevatedButton(
          onPressed: _takePicture,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('撮影'),
         ),
      ];
    } else if (_imageFile != null) {
      actionButtons = [
        ElevatedButton(
          onPressed: _goBack, //通常の戻る動作
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('< 戻る'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _startCamera, //再撮影
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('再撮影'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _completeAndProceed, //完了ボタン
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('完了'),
        ),
      ];
    } else {
      //初期状態
      actionButtons = [
        ElevatedButton(
          onPressed: _goBack,//通常の戻る動作
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('< 戻る'),
        ),
        const SizedBox(width: 70), //元のレイアウトに合わせる

        ElevatedButton(
          onPressed: _startCamera, //カメラ起動
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('カメラ起動'),
        ),
      ];
    }

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          mainContent, //カメラプレビューor画像or初期メッセージ
          if (_upperImageBytes != null)
            Positioned(
              top: 30,
              left: 30,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const Text('マスク画像（ダミー）プレビュー'),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.memory(_upperImageBytes!),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("画像を編集してください",
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min, //ボタンを最小限の幅にする
                children: actionButtons, //アクションボタン類を配置
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CameraPreviewWidget: カメラプレビュー表示用
class CameraPreviewWidget extends StatelessWidget {
  final CameraHandler cameraHandler;
  const CameraPreviewWidget({Key? key, required this.cameraHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!cameraHandler.isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(cameraHandler.controller!);
  }
}