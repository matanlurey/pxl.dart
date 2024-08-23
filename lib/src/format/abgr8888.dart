part of '../format.dart';

/// 32-bit ABGR pixel format with four 8-bit channels.
///
/// This is the package's canonical integer-based pixel format.
///
/// {@category Pixel Formats}
const abgr8888 = Abgr8888._();

/// 32-bit ABGR pixel format with four 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [abgr8888].
///
/// {@category Pixel Formats}
final class Abgr8888 extends Rgba<int, int> {
  const Abgr8888._();

  @override
  String get name => 'ABGR8888';

  @override
  int get bytesPerPixel => Uint32List.bytesPerElement;

  @override
  int get zero => 0x00000000;

  @override
  int get max => 0xFFFFFFFF;

  @override
  int clamp(int pixel) => pixel & max;

  @override
  double distance(int a, int b) {
    final dr = getRed(a) - getRed(b);
    final dg = getGreen(a) - getGreen(b);
    final db = getBlue(a) - getBlue(b);
    final da = getAlpha(a) - getAlpha(b);
    return (dr * dr + dg * dg + db * db + da * da).toDouble();
  }

  @override
  int copyWith(
    int pixel, {
    int? red,
    int? green,
    int? blue,
    int? alpha,
  }) {
    var output = pixel;
    if (red != null) {
      output = (output & 0x00FFFFFF) | (red & 0xFF) << 24;
    }
    if (green != null) {
      output = (output & 0xFF00FFFF) | (green & 0xFF) << 16;
    }
    if (blue != null) {
      output = (output & 0xFFFF00FF) | (blue & 0xFF) << 8;
    }
    if (alpha != null) {
      output = (output & 0xFFFFFF00) | (alpha & 0xFF);
    }
    return output;
  }

  @override
  int copyWithNormalized(
    int pixel, {
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) {
    var output = pixel;
    if (red != null) {
      output &= 0x00FFFFFF;
      output |= (red.clamp(0.0, 1.0) * 0xFF).floor() << 24;
    }
    if (green != null) {
      output &= 0xFF00FFFF;
      output |= (green.clamp(0.0, 1.0) * 0xFF).floor() << 16;
    }
    if (blue != null) {
      output &= 0xFFFF00FF;
      output |= (blue.clamp(0.0, 1.0) * 0xFF).floor() << 8;
    }
    if (alpha != null) {
      output &= 0xFFFFFF00;
      output |= (alpha.clamp(0.0, 1.0) * 0xFF).floor();
    }
    return output;
  }

  @override
  int get minRed => 0x00;

  @override
  int get minGreen => 0x00;

  @override
  int get minBlue => 0x00;

  @override
  int get minAlpha => 0x00;

  @override
  int get maxRed => 0xFF;

  @override
  int get maxGreen => 0xFF;

  @override
  int get maxBlue => 0xFF;

  @override
  int get maxAlpha => 0xFF;

  @override
  int getRed(int pixel) => (pixel >> 24) & 0xFF;

  @override
  int getGreen(int pixel) => (pixel >> 16) & 0xFF;

  @override
  int getBlue(int pixel) => (pixel >> 8) & 0xFF;

  @override
  int getAlpha(int pixel) => pixel & 0xFF;

  @override
  int fromAbgr8888(int pixel) => pixel;

  @override
  int toAbgr8888(int pixel) => pixel;

  @override
  Float32x4 toFloatRgba(int pixel) => floatRgba.fromAbgr8888(pixel);
}
