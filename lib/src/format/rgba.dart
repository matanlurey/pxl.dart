part of '../format.dart';

/// Base API for pixel formats that have red, green, blue, and alpha channels.
///
/// Additional RGBA-specific methods are provided:
/// - [copyWith] and [copyWithNormalized] for replacing channel values;
/// - [maxRed], [maxGreen], [maxBlue], and [maxAlpha] for the maximum channel
///   values;
/// - [black], [white], [red], [green], [blue], [yellow], [cyan], and [magenta]
///   for common colors.
///
/// In addition, [fromFloatRgba] is implemented using [copyWithNormalized].
///
/// {@category Pixel Formats}
abstract final class Rgba<P, C> extends Rgb<P, C> {
  /// @nodoc
  const Rgba();

  @override
  P get black => create();

  /// Creates a new pixel with the given channel values.
  ///
  /// The [red], [green], [blue], and [alpha] values are optional.
  ///
  /// If omitted, the corresponding channel value is set to the minimum value,
  /// except for the alpha channel which is set to the maximum value by default.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Creating a fully opaque red pixel.
  /// final pixel = abgr8888.create(red: 0xFF);
  ///
  /// // Creating a semi-transparent red pixel.
  /// final pixel = abgr8888.create(red: 0xFF, alpha: 0x80);
  /// ```
  @override
  P create({
    C? red,
    C? green,
    C? blue,
    C? alpha,
  }) {
    return copyWith(
      zero,
      red: red ?? minRed,
      green: green ?? minGreen,
      blue: blue ?? minBlue,
      alpha: alpha ?? maxAlpha,
    );
  }

  @override
  P createNormalized({
    double red = 0.0,
    double green = 0.0,
    double blue = 0.0,
    double alpha = 1.0,
  }) {
    return copyWithNormalized(
      zero,
      red: red,
      green: green,
      blue: blue,
      alpha: alpha,
    );
  }

  /// The minimum value for the alpha channel.
  C get minAlpha;

  /// The maximum value for the alpha channel.
  C get maxAlpha;

  @override
  P copyWith(
    P pixel, {
    C? red,
    C? green,
    C? blue,
    C? alpha,
  });

  @override
  P copyWithNormalized(
    P pixel, {
    double? red,
    double? green,
    double? blue,
    double? alpha,
  });

  /// Returns the alpha channel value of the [pixel].
  C getAlpha(P pixel);

  @override
  P fromFloatRgba(Float32x4 pixel) {
    return copyWithNormalized(
      zero,
      red: pixel.x,
      green: pixel.y,
      blue: pixel.z,
      alpha: pixel.w,
    );
  }
}

abstract final class _Rgba8x4Int extends Rgba<int, int> with _Rgb8Int {
  const _Rgba8x4Int.fromOffsets({
    required int r,
    required int g,
    required int b,
    required int a,
  })  : // coverage:ignore-start
        _maskAlpha = 0xFF << a,
        _maskRed = 0xFF << r,
        _maskGreen = 0xFF << g,
        _maskBlue = 0xFF << b,
        // coverage:ignore-end
        _offsetAlpha = a,
        _offsetRed = r,
        _offsetGreen = g,
        _offsetBlue = b;

  final int _maskAlpha;
  final int _maskRed;
  final int _maskGreen;
  final int _maskBlue;
  final int _offsetAlpha;
  final int _offsetRed;
  final int _offsetGreen;
  final int _offsetBlue;

  @override
  @nonVirtual
  int get bytesPerPixel => Uint32List.bytesPerElement;

  @override
  @nonVirtual
  int get max => 0xFFFFFFFF;

  @override
  @nonVirtual
  double distance(int a, int b) {
    final dr = getRed(a) - getRed(b);
    final dg = getGreen(a) - getGreen(b);
    final db = getBlue(a) - getBlue(b);
    final da = getAlpha(a) - getAlpha(b);
    return (dr * dr + dg * dg + db * db + da * da).toDouble();
  }

  @override
  @nonVirtual
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
  @nonVirtual
  int get minAlpha => 0x00;

  @override
  @nonVirtual
  int get maxAlpha => 0xFF;

  @override
  @nonVirtual
  Float32x4 toFloatRgba(int pixel) {
    final r = getRed(pixel) / 255.0;
    final g = getGreen(pixel) / 255.0;
    final b = getBlue(pixel) / 255.0;
    final a = getAlpha(pixel) / 255.0;
    return Float32x4(r, g, b, a);
  }

  @override
  @nonVirtual
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
      output |= (red & 0xFF) << _offsetRed;
    }
    if (green != null) {
      output &= ~_maskGreen;
      output |= (green & 0xFF) << _offsetGreen;
    }
    if (blue != null) {
      output &= ~_maskBlue;
      output |= (blue & 0xFF) << _offsetBlue;
    }
    if (alpha != null) {
      output &= ~_maskAlpha;
      output |= (alpha & 0xFF) << _offsetAlpha;
    }
    return output;
  }

  @override
  @nonVirtual
  int getRed(int pixel) => (pixel >> _offsetRed) & 0xFF;

  @override
  @nonVirtual
  int getGreen(int pixel) => (pixel >> _offsetGreen) & 0xFF;

  @override
  @nonVirtual
  int getBlue(int pixel) => (pixel >> _offsetBlue) & 0xFF;

  @override
  @nonVirtual
  int getAlpha(int pixel) => (pixel >> _offsetAlpha) & 0xFF;

  @override
  int fromAbgr8888(int pixel) {
    return create(
      red: abgr8888.getRed(pixel),
      green: abgr8888.getGreen(pixel),
      blue: abgr8888.getBlue(pixel),
      alpha: abgr8888.getAlpha(pixel),
    );
  }

  @override
  int toAbgr8888(int pixel) {
    return abgr8888.create(
      red: getRed(pixel),
      green: getGreen(pixel),
      blue: getBlue(pixel),
      alpha: getAlpha(pixel),
    );
  }
}
