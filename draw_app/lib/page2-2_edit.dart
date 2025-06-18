import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/rendering.dart'; //画像を合成するパッケージ

class Page2Edit extends StatefulWidget {
  final File underImageFile; // 下層画像（例: カメラで撮影した画像）
  final Uint8List upperImageBytes; // 上層画像（例: 透過PNG）

  const Page2Edit({
    Key? key,
    required this.underImageFile,
    required this.upperImageBytes,
  }) : super(key: key);

  @override
  State<Page2Edit> createState() => _Page2EditState();
}

class _Page2EditState extends State<Page2Edit> {
  final GlobalKey _repaintKey = GlobalKey(); // レイヤー合成用のキー

  double _rotation = 0.0; // 回転角度
  int? _maskWidth; // マスク画像の幅
  int? _maskHeight; // マスク画像の高さ
  Timer? _rotateTimer; // 回転タイマー

  @override
  void initState() {
    super.initState();
    _loadMaskSize(); // マスク画像のサイズを取得
  }

  Future<void> _loadMaskSize() async {
    final codec = await ui.instantiateImageCodec(widget.upperImageBytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _maskWidth = frame.image.width;
      _maskHeight = frame.image.height;
    });
  }

  // レイヤー合成して画像として保存
  Future<File> _exportEditedImage() async {
    RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);
    return file;
  }

  void _goBack() {
    // 前の画面に戻る
    context.pop();
  }

  void _completeAndProceed() async {
    // 編集した画像を保存して次の画面へ
    final editedImage = await _exportEditedImage();
    context.push('/c', extra: editedImage);
  }

  void _startRotation(double speed) {
    _rotateTimer?.cancel(); // 既存のタイマーをキャンセル
    _rotateTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _rotation += speed;
      });
    });
  }

  void _stopRotation() {
    _rotateTimer?.cancel();
    _rotateTimer = null;
  }

  @override
  void dispose() {
    _rotateTimer?.cancel(); // タイマーを解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.green,
      title: const Text('編集'),
    );

    Widget mainContent;
    if (_maskWidth == null || _maskHeight == null) {
      // マスク画像のサイズがまだ取得できていない場合
      mainContent = const Center(child: CircularProgressIndicator());
    } else {
      //画面サイズを取得
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height - kToolbarHeight; // AppBar分を引く

      //マスク画像が画像内に収まるように最大サイズを計算
      final widthRatio = screenWidth / _maskWidth!;
      final heightRatio = screenHeight / _maskHeight!;
      final scale = widthRatio < heightRatio ? widthRatio : heightRatio;

      final displayWidth = _maskWidth! * scale;
      final displayHeight = _maskHeight! * scale;

      mainContent = Center(
        child: RepaintBoundary(
          key: _repaintKey,
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: Stack(
              children: [
                InteractiveViewer(
                  minScale: 0.2,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: Transform.rotate(
                    angle: _rotation,
                    child: Image.file(
                      widget.underImageFile,
                      fit: BoxFit.contain,
                      width: displayWidth,
                      height: displayHeight,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Image.memory(
                    widget.upperImageBytes,
                    fit: BoxFit.cover,
                    width: displayWidth,
                    height: displayHeight,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> actionButtons = [
      ElevatedButton(
        onPressed: _goBack, // 戻るボタン
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('< 戻る'),
      ),
      const SizedBox(width: 10), // ボタン間のスペース
      ElevatedButton(
        onPressed: _completeAndProceed, // 完了ボタン
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text('完了'),
      ),
    ];

    //回転ボタン(左・右)
    Widget rotateLeftButton = GestureDetector(
      onTap: () {
        setState(() {
          _rotation -= 0.1; // 左回転
        });
      },
      onLongPressStart: (_) {
        _startRotation(-0.05); // 長押しで回転速度アップ
      },
      onLongPressEnd: (_) {
        _stopRotation(); // 長押し終了で回転停止
      },
      child: FloatingActionButton(
        heroTag: 'rotateLeft',
        backgroundColor: Colors.blue,
        onPressed: null, // タップイベントはGestureDetectorで処理
        child: const Icon(Icons.rotate_left),
      )
    );

    Widget rotateRightButton = GestureDetector(
      onTap: () {
        setState(() {
          _rotation += 0.1; // 右回転
        });
      },
      onLongPressStart: (_) {
        _startRotation(0.05); // 長押しで回転速度アップ
      },
      onLongPressEnd: (_) {
        _stopRotation(); // 長押し終了で回転停止
      },
      child: FloatingActionButton(
        heroTag: 'rotateRight',
        backgroundColor: Colors.blue,
        onPressed: null, // タップイベントはGestureDetectorで処理
        child: const Icon(Icons.rotate_right),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          mainContent,
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actionButtons,
              ),
            ),
          ),
          //回転ボタン(右下)
          Positioned(
            bottom: 100,
            right: 40,
            child: rotateRightButton,
          ),
          Positioned(
            bottom: 170,
            right: 40,
            child: rotateLeftButton,
          ),
        ],
      )
    );
  }
}