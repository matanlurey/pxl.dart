part of '../format.dart';

/// 32-bit ABGR pixel format with four 8-bit channels.
///
/// This is the package's canonical integer-based pixel format.
///
/// Colors in this format are represented as follows:
///
/// Color        | Value
/// -------------|------
/// [Rgba.red]   | `0xFFFF0000`
/// [Rgba.green] | `0xFF00FF00`
/// [Rgba.blue]  | `0xFF0000FF`
/// [Rgba.white] | `0xFFFFFFFF`
/// [Rgba.black] | `0xFF000000`
///
/// {@category Pixel Formats}
const abgr8888 = Abgr8888._();

/// 32-bit ABGR pixel format with four 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [abgr8888].
///
/// {@category Pixel Formats}
final class Abgr8888 extends Rgba<int, int> {
  static const _maskAlpha = 0xFF000000;
  static const _maskRed = 0x00FF0000;
  static const _maskGreen = 0x0000FF00;
  static const _maskBlue = 0x000000FF;
  static const _bitsAlpha = 24;
  static const _bitsRed = 16;
  static const _bitsGreen = 8;
  static const _bitsBlue = 0;

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
      output &= ~_maskRed;
      output |= (red & 0xFF) << _bitsRed;
    }
    if (green != null) {
      output &= ~_maskGreen;
      output |= (green & 0xFF) << _bitsGreen;
    }
    if (blue != null) {
      output &= ~_maskBlue;
      output |= (blue & 0xFF) << _bitsBlue;
    }
    if (alpha != null) {
      output &= ~_maskAlpha;
      output |= (alpha & 0xFF) << _bitsAlpha;
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
    return copyWith(
      pixel,
      red: red != null ? (red.clamp(0.0, 1.0) * 0xFF).floor() : null,
      green: green != null ? (green.clamp(0.0, 1.0) * 0xFF).floor() : null,
      blue: blue != null ? (blue.clamp(0.0, 1.0) * 0xFF).floor() : null,
      alpha: alpha != null ? (alpha.clamp(0.0, 1.0) * 0xFF).floor() : null,
    );
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
  int getRed(int pixel) => (pixel >> _bitsRed) & 0xFF;

  @override
  int getGreen(int pixel) => (pixel >> _bitsGreen) & 0xFF;

  @override
  int getBlue(int pixel) => (pixel >> _bitsBlue) & 0xFF;

  @override
  int getAlpha(int pixel) => (pixel >> _bitsAlpha) & 0xFF;

  @override
  int fromAbgr8888(int pixel) => pixel;

  @override
  int toAbgr8888(int pixel) => pixel;

  @override
  Float32x4 toFloatRgba(int pixel) => floatRgba.fromAbgr8888(pixel);
}
