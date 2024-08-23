part of '../format.dart';

/// A 32-bit[^1] RGB pixel format with three 8-bit channels.
///
/// [^1]: The maximum size of individual pixels can be represented by 24 bits.
///
/// {@category Pixel Formats}
const rgb888 = Rgb888._();

/// A 32-bit[^1] RGB pixel format with three 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [rgb888].
///
/// {@category Pixel Formats}
final class Rgb888 extends Rgb<int, int> {
  const Rgb888._();

  @override
  String get name => 'RGB888';

  @override
  int get bytesPerPixel => Uint32List.bytesPerElement;

  @override
  int get zero => 0x000000;

  @override
  int get max => 0xFFFFFF;

  @override
  int clamp(int pixel) => pixel & max;

  @override
  double distance(int a, int b) {
    final dr = getRed(a) - getRed(b);
    final dg = getGreen(a) - getGreen(b);
    final db = getBlue(a) - getBlue(b);
    return (dr * dr + dg * dg + db * db).toDouble();
  }

  @override
  int copyWith(
    int pixel, {
    int? red,
    int? green,
    int? blue,
  }) {
    var output = pixel;
    if (red != null) {
      output = (output & 0x00FFFF) | (red & 0xFF) << 16;
    }
    if (green != null) {
      output = (output & 0xFF00FF) | (green & 0xFF) << 8;
    }
    if (blue != null) {
      output = (output & 0xFFFF00) | (blue & 0xFF);
    }
    return output;
  }

  @override
  int copyWithNormalized(
    int pixel, {
    double? red,
    double? green,
    double? blue,
  }) {
    var output = pixel;
    if (red != null) {
      output &= 0x00FFFF;
      output |= (red.clamp(0.0, 1.0) * 0xFF).floor() << 16;
    }
    if (green != null) {
      output &= 0xFF00FF;
      output |= (green.clamp(0.0, 1.0) * 0xFF).floor() << 8;
    }
    if (blue != null) {
      output &= 0xFFFF00;
      output |= (blue.clamp(0.0, 1.0) * 0xFF).floor();
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
  int get maxRed => 0xFF;

  @override
  int get maxGreen => 0xFF;

  @override
  int get maxBlue => 0xFF;

  @override
  int getRed(int pixel) => (pixel >> 16) & 0xFF;

  @override
  int getGreen(int pixel) => (pixel >> 8) & 0xFF;

  @override
  int getBlue(int pixel) => pixel & 0xFF;

  @override
  int fromAbgr8888(int pixel) => swapLane13(pixel & 0xFFFFFF);

  @override
  int toAbgr8888(int pixel) => swapLane13(pixel | 0xFF000000);

  @override
  Float32x4 toFloatRgba(int pixel) {
    final p = Float32x4(
      getRed(pixel).toDouble(),
      getGreen(pixel).toDouble(),
      getBlue(pixel).toDouble(),
      0xFF,
    );
    return p / Float32x4.splat(0xFF);
  }
}
