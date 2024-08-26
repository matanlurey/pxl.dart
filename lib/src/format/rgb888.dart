part of '../format.dart';

/// 24-bit[^1] RGB pixel format with three 8-bit channels.
///
/// Colors in this format are represented as follows:
///
/// Color       | Value
/// ------------|------
/// [Rgb.red]   | `0xFF0000`
/// [Rgb.green] | `0x00FF00`
/// [Rgb.blue]  | `0x0000FF`
/// [Rgb.white] | `0xFFFFFF`
/// [Rgb.black] | `0x000000`
///
/// [^1]: The 24-bit RGB format is a 32-bit format with 8 unused bits.
///
/// {@category Pixel Formats}
const rgb888 = Rgb888._();

/// 24-bit[^1] RGB pixel format with three 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [rgb888].
///
/// [^1]: The 24-bit RGB format is a 32-bit format with 8 unused bits.
///
/// {@category Pixel Formats}
final class Rgb888 extends Rgb<int, int> with _Rgb8Int {
  const Rgb888._();

  @override
  String get name => 'RGB888';

  @override
  int get bytesPerPixel => Uint32List.bytesPerElement;

  @override
  int get max => 0xFFFFFF;

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
      output = (output & 0x00FFFF) | ((red & 0xFF) << 16);
    }
    if (green != null) {
      output = (output & 0xFF00FF) | ((green & 0xFF) << 8);
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
    return copyWith(
      pixel,
      red: red != null ? (red.clamp(0.0, 1.0) * 0xFF).floor() : null,
      green: green != null ? (green.clamp(0.0, 1.0) * 0xFF).floor() : null,
      blue: blue != null ? (blue.clamp(0.0, 1.0) * 0xFF).floor() : null,
    );
  }

  @override
  Float32x4 toFloatRgba(int pixel) {
    return Float32x4(
      getRed(pixel) / 255.0,
      getGreen(pixel) / 255.0,
      getBlue(pixel) / 255.0,
      1.0,
    );
  }

  @override
  int fromFloatRgba(Float32x4 pixel) {
    return copyWithNormalized(
      zero,
      red: pixel.x,
      green: pixel.y,
      blue: pixel.z,
    );
  }

  @override
  int getRed(int pixel) => (pixel >> 16) & 0xFF;

  @override
  int getGreen(int pixel) => (pixel >> 8) & 0xFF;

  @override
  int getBlue(int pixel) => pixel & 0xFF;

  @override
  int fromAbgr8888(int pixel) {
    return create(
      red: abgr8888.getRed(pixel),
      green: abgr8888.getGreen(pixel),
      blue: abgr8888.getBlue(pixel),
    );
  }

  @override
  int toAbgr8888(int pixel) {
    return abgr8888.create(
      red: getRed(pixel),
      green: getGreen(pixel),
      blue: getBlue(pixel),
    );
  }
}
