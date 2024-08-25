part of '../format.dart';

/// A 128-bit floating-point RGBA pixel format with four 32-bit channels.
///
/// This is the package's canonical floating-point pixel format.
///
/// {@category Pixel Formats}
const floatRgba = FloatRgba._();

/// A 128-bit floating-point RGBA pixel format with four 32-bit channels.
///
/// For a singleton instance of this class, and further details, see
/// [floatRgba].
///
/// {@category Pixel Formats}
final class FloatRgba extends Rgba<Float32x4, double> {
  const FloatRgba._();

  @override
  String get name => 'FLOAT_RGBA';

  @override
  int get bytesPerPixel => Float32x4List.bytesPerElement;

  @override
  Float32x4 get zero => Float32x4.zero();

  @override
  Float32x4 get max => Float32x4.splat(1.0);

  @override
  Float32x4 clamp(Float32x4 pixel) => pixel.clamp(zero, max);

  @override
  double distance(Float32x4 a, Float32x4 b) {
    var d = a - b;
    d *= d;
    return d.x + d.y + d.z + d.w;
  }

  @override
  Float32x4 copyWith(
    Float32x4 pixel, {
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) {
    final output = Float32x4(
      red ?? getRed(pixel),
      green ?? getGreen(pixel),
      blue ?? getBlue(pixel),
      alpha ?? getAlpha(pixel),
    );
    return output.clamp(zero, max);
  }

  @override
  Float32x4 copyWithNormalized(
    Float32x4 pixel, {
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) {
    return copyWith(pixel, red: red, green: green, blue: blue, alpha: alpha);
  }

  @override
  double get minRed => 0.0;

  @override
  double get minGreen => 0.0;

  @override
  double get minBlue => 0.0;

  @override
  double get minAlpha => 0.0;

  @override
  double get maxRed => 1.0;

  @override
  double get maxGreen => 1.0;

  @override
  double get maxBlue => 1.0;

  @override
  double get maxAlpha => 1.0;

  @override
  double getRed(Float32x4 pixel) => pixel.x;

  @override
  double getGreen(Float32x4 pixel) => pixel.y;

  @override
  double getBlue(Float32x4 pixel) => pixel.z;

  @override
  double getAlpha(Float32x4 pixel) => pixel.w;

  @override
  Float32x4 fromAbgr8888(int pixel) => abgr8888.toFloatRgba(pixel);

  @override
  int toAbgr8888(Float32x4 pixel) {
    return abgr8888.fromFloatRgba(pixel);
  }

  @override
  Float32x4 fromFloatRgba(Float32x4 pixel) => pixel;

  @override
  Float32x4 toFloatRgba(Float32x4 pixel) => pixel;
}
