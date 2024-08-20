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
abstract final class Rgba<P, C> extends PixelFormat<P, C> {
  /// @nodoc
  const Rgba();

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

  /// The maximum value for the red channel.
  C get maxRed;

  /// The maximum value for the green channel.
  C get maxGreen;

  /// The maximum value for the blue channel.
  C get maxBlue;

  /// The maximum value for the alpha channel.
  C get maxAlpha;

  /// Black color with full transparency.
  P get black {
    return copyWith(zero, alpha: maxAlpha);
  }

  /// White color with full transparency.
  P get white {
    return copyWith(
      max,
      red: maxRed,
      green: maxGreen,
      blue: maxBlue,
      alpha: maxAlpha,
    );
  }

  /// Red color with full transparency.
  P get red {
    return copyWith(zero, red: maxRed, alpha: maxAlpha);
  }

  /// Green color with full transparency.
  P get green {
    return copyWith(zero, green: maxGreen, alpha: maxAlpha);
  }

  /// Blue color with full transparency.
  P get blue {
    return copyWith(zero, blue: maxBlue, alpha: maxAlpha);
  }

  /// Yellow color with full transparency.
  P get yellow {
    return copyWith(zero, red: maxRed, green: maxGreen, alpha: maxAlpha);
  }

  /// Cyan color with full transparency.
  P get cyan {
    return copyWith(zero, green: maxGreen, blue: maxBlue, alpha: maxAlpha);
  }

  /// Magenta color with full transparency.
  P get magenta {
    return copyWith(zero, red: maxRed, blue: maxBlue, alpha: maxAlpha);
  }

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
