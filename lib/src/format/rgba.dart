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
