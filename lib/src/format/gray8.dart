part of '../format.dart';

/// 8-bit grayscale pixel format.
///
/// Colors in this format are represented as follows:
///
/// Color         | Value
/// --------------|------
/// [Gray8.black] | `0x00`
/// [Gray8.white] | `0xFF`
///
/// {@category Pixel Formats}
const gray8 = Gray8._();

/// 8-bit grayscale pixel format.
///
/// For a singleton instance of this class, and further details, see [gray8].
///
/// {@category Pixel Formats}
final class Gray8 extends _GrayInt {
  const Gray8._();

  @override
  String get name => 'GRAY8';

  @override
  int get bytesPerPixel => Uint8List.bytesPerElement;

  @override
  int get maxGray => 0xFF;

  @override
  int get max => maxGray;

  @override
  int copyWith(int pixel, {int? gray}) {
    var output = pixel;
    if (gray != null) {
      output = gray & 0xFF;
    }
    return output;
  }

  @override
  int copyWithNormalized(int pixel, {double? gray}) {
    return copyWith(
      pixel,
      gray: gray != null ? (gray.clamp(0.0, 1.0) * 0xFF).floor() : null,
    );
  }

  @override
  int getGray(int pixel) => pixel & 0xFF;

  @override
  int fromAbgr8888(int pixel) {
    return _luminanceRgb888(
      abgr8888.getRed(pixel),
      abgr8888.getGreen(pixel),
      abgr8888.getBlue(pixel),
    );
  }

  @override
  int toAbgr8888(int pixel) {
    // Isolate the least significant 8 bits.
    final value = pixel & 0xFF;

    // Replicate the value across all channels (R, G, B).
    final asRgb = value * 0x010101;

    // Set the alpha channel to 0xFF.
    return asRgb | 0xFF000000;
  }

  @override
  Float32x4 toFloatRgba(int pixel) {
    final g = getGray(pixel) / 255.0;
    return Float32x4(g, g, g, 1.0);
  }
}
