library masker;

import 'dart:typed_data';

import 'src/mask.dart' as impl;

/// 共通 API：あとでネイティブ実装に差し替えてもここは不変
class RegionMask {
  /// [pngBytes] : PNG 画像バイト列
  /// [seedX], [seedY] : 白領域の起点座標
  static Future<Uint8List> extractWhiteRegion(
      Uint8List pngBytes, int seedX, int seedY) {
    return impl.extractWhiteRegion(pngBytes, seedX, seedY);
  }
}
