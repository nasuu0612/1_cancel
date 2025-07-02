import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart'; // computeを使うため

// b1

class Page2Select extends StatefulWidget {
  final File underImageFile; // 撮影された下の画像（写真）

  const Page2Select({Key? key, required this.underImageFile}) : super(key: key);

  @override
  State<Page2Select> createState() => _Page2SelectState();
}

class _Page2SelectState extends State<Page2Select> {
  final int maskCount = 30; // マスク画像の枚数（mask_0.png〜mask_29.png）
  late List<String> maskAssetPaths;

  List<img.Image?> decodedMasks = []; // 各マスク画像のデコード結果を保持
  img.Image? decodedLineImage; // 線画画像（line.png）

  int? selectedRegionIndex; // ユーザーが選択したマスク番号
  Uint8List? previewImageBytes; // UI上に表示するプレビュー画像
  bool isMerging = false; // 合成処理中かどうか

  @override
  void initState() {
    super.initState();

    // マスク画像のパスを生成
    maskAssetPaths = List.generate(
      maskCount,
      (i) => 'assets/PaintApp_illust/mask_$i.png',
    );

    // マスクと線画画像を読み込む
    _loadImages();
  }

  // マスク画像と線画画像(line.png)を読み込んで保持する
  Future<void> _loadImages() async {
    decodedMasks.clear();

    // 各マスク画像を読み込んで decodePng して配列に追加
    for (var path in maskAssetPaths) {
      final data = await rootBundle.load(path);
      final decoded = await compute(decodeImage, data.buffer.asUint8List());
      decodedMasks.add(decoded);
    }

    // 線画画像(line.png)を読み込んで保持
    final lineData = await rootBundle.load('assets/PaintApp_illust/line.png');
    final decodedLine = await compute(
      decodeImage,
      lineData.buffer.asUint8List(),
    );
    decodedLineImage = decodedLine;

    // プレビュー用画像を初期表示に設定
    if (decodedLineImage != null) {
      previewImageBytes = Uint8List.fromList(img.encodePng(decodedLineImage!));
    }

    setState(() {});
  }

  // タップされた座標がどのマスクに含まれるか判定
  int? detectTappedRegion(int x, int y) {
    for (int i = 0; i < decodedMasks.length; i++) {
      final mask = decodedMasks[i];
      if (mask == null) continue;
      if (x < 0 || x >= mask.width || y < 0 || y >= mask.height) continue;

      final pixel = mask.getPixel(x, y);
      if (pixel.a > 0) return i; // 透明でなければ領域と判定
    }
    return null;
  }

  // illust.pngから選択された領域だけを透明化して返す
  Future<Uint8List?> removeSelectedRegionFromIllust(int selectedIndex) async {
    final data = await rootBundle.load('assets/PaintApp_illust/illust.png');
    final illust = img.decodePng(data.buffer.asUint8List());
    if (illust == null ||
        selectedIndex < 0 ||
        selectedIndex >= decodedMasks.length) {
      return null;
    }

    final mask = decodedMasks[selectedIndex];
    if (mask == null) return null;

    final output = img.Image.from(illust);

    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        final maskPixel = mask.getPixel(x, y);
        if (maskPixel.a > 0) {
          output.setPixelRgba(x, y, 0, 0, 0, 0); // 透明にする
        }
      }
    }

    return Uint8List.fromList(img.encodePng(output));
  }

  // 選択されたマスク領域を赤色でハイライト表示する
  Future<Uint8List?> applyHighlight(int index) async {
    if (decodedLineImage == null || index < 0 || index >= decodedMasks.length)
      return null;

    final base = img.Image.from(decodedLineImage!);
    final mask = decodedMasks[index];
    if (mask == null) return null;

    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        final pixel = mask.getPixel(x, y);
        if (pixel.a > 0) {
          base.setPixelRgba(x, y, 255, 0, 0, 128); // 赤の半透明で重ねる
        }
      }
    }

    return Uint8List.fromList(img.encodePng(base));
  }

  // タップ座標を画像座標に変換
  Offset? convertToImageCoordinates(
    TapDownDetails details,
    BoxConstraints constraints,
    img.Image baseImage,
  ) {
    final localPos = details.localPosition;
    final scaleX = baseImage.width / constraints.maxWidth;
    final scaleY = baseImage.height / constraints.maxHeight;
    final x = (localPos.dx * scaleX).toInt();
    final y = (localPos.dy * scaleY).toInt();
    return Offset(x.toDouble(), y.toDouble());
  }

  // タップされたときの処理
  void onTapDown(TapDownDetails details, BoxConstraints constraints) async {
    if (decodedLineImage == null) return;

    final pos = convertToImageCoordinates(
      details,
      constraints,
      decodedLineImage!,
    );
    if (pos == null) return;

    final tappedIndex = detectTappedRegion(pos.dx.toInt(), pos.dy.toInt());
    if (tappedIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('領域が見つかりません')));
      return;
    }

    final highlighted = await applyHighlight(tappedIndex);
    if (highlighted == null) return;

    setState(() {
      selectedRegionIndex = tappedIndex;
      previewImageBytes = highlighted;
    });
  }

  // 完了ボタンが押されたときの処理（合成して次の画面へ）
  Future<void> onCompletePressed() async {
    if (selectedRegionIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('領域が選択されていません')));
      return;
    }

    setState(() => isMerging = true);

    final merged = await removeSelectedRegionFromIllust(selectedRegionIndex!);

    setState(() => isMerging = false);

    if (merged == null) return;

    // 次の画面（Page2Edit）へ遷移し、画像を渡す
    context.push(
      '/b2',
      extra: {
        'underImageFile': widget.underImageFile,
        'upperImageBytes': merged,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select')),
      body: decodedLineImage == null
          ? const Center(child: CircularProgressIndicator()) // 読み込み中
          : LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => onTapDown(details, constraints),
                  child: Stack(
                    children: [
                      Center(
                        child: previewImageBytes != null
                            ? Image.memory(
                                previewImageBytes!,
                                fit: BoxFit.contain,
                              )
                            : Container(),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: isMerging
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: onCompletePressed,
                                  child: const Text('完了'),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// --- computeで使う関数（トップレベル） ---
img.Image? decodeImage(Uint8List bytes) => img.decodePng(bytes);
