import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

const int whiteThreshold = 190;

/// 白黒 2値画像を対象に、
/// ― 指定シードから連結する “白(#FFFFFF) 領域” を flood‑fill
/// ― 領域内を α=0（透過）、それ以外を α=255 に書き換えた PNG を返す
Future<Uint8List> extractWhiteRegion(
  Uint8List pngBytes,
  int seedX,
  int seedY,
) async {
  // 1️⃣ デコード & 4ch化
  final src = img.decodeImage(pngBytes)!;
  final img.Image rgba =
      src.numChannels == 4 ? src : src.convert(numChannels: 4);

  final w = rgba.width, h = rgba.height;

  // 2️⃣ Flood‑Fill マスク生成
  final Uint8List mask = Uint8List(w * h);         // 1 = inside
  final Queue<math.Point<int>> q =
      Queue()..add(math.Point(seedX.clamp(0, w - 1), seedY.clamp(0, h - 1)));

  bool isWhite(img.Pixel p) {
    final y = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
    return y >= whiteThreshold;      // 判定
  }

  while (q.isNotEmpty) {
    final p = q.removeFirst();
    final idx = p.y * w + p.x;
    if (mask[idx] == 1) continue;
    if (!isWhite(rgba.getPixel(p.x, p.y))) continue;

    mask[idx] = 1;                                // 塗りつぶし
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = p.x + dx, ny = p.y + dy;
        if (0 <= nx && nx < w && 0 <= ny && ny < h) {
          if (mask[ny * w + nx] == 0) q.add(math.Point(nx, ny));
        }
      }
    }
  }

  // 3️⃣ αチャネル書き換え
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final idx = y * w + x;
      final pix = rgba.getPixel(x, y);
      final a = mask[idx] == 1 ? 0 : 255;         // 白領域 → 透過
      rgba.setPixelRgba(x, y, pix.r.toInt(), pix.g.toInt(), pix.b.toInt(), a);
    }
  }

  // 4️⃣ PNG エンコード
  return Uint8List.fromList(img.encodePng(rgba));
}
