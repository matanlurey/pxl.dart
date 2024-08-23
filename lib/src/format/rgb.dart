part of '../format.dart';

/// Base API for pixel formats that have red, green, and blue channels.
///
/// Additional RGBA-specific methods are provided:
/// - [copyWith] and [copyWithNormalized] for replacing channel values;
/// - [maxRed], [maxGreen], and [maxBlue] for the maximum channel values;
/// - [black], [white], [red], [green], [blue], [yellow], [cyan], and [magenta]
///   for common colors.
///
/// In addition, [fromFloatRgba] is implemented using [copyWithNormalized].
///
/// {@category Pixel Formats}
abstract final class Rgb<P, C> extends PixelFormat<P, C> {
  /// @nodoc
  const Rgb();

  /// Creates a new pixel with the given channel values.
  ///
  /// The [red], [green], and [blue] values are optional.
  ///
  /// If omitted, the corresponding channel value is set to the minimum value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Creating a full red pixel.
  /// final pixel = rgb.create(red: 0xFF);
  /// ```
  P create({
    C? red,
    C? green,
    C? blue,
  }) {
    return copyWith(
      zero,
      red: red ?? minRed,
      green: green ?? minGreen,
      blue: blue ?? minBlue,
    );
  }

  @override
  P copyWith(
    P pixel, {
    C? red,
    C? green,
    C? blue,
  });

  @override
  P copyWithNormalized(
    P pixel, {
    double? red,
    double? green,
    double? blue,
  });

  /// The minimum value for the red channel.
  C get minRed;

  /// The minimum value for the green channel.
  C get minGreen;

  /// The minimum value for the blue channel.
  C get minBlue;

  /// The maximum value for the red channel.
  C get maxRed;

  /// The maximum value for the green channel.
  C get maxGreen;

  /// The maximum value for the blue channel.
  C get maxBlue;

  /// Black color with full transparency.
  P get black => zero;

  /// White color with full transparency.
  P get white => max;

  /// Red color with full transparency.
  P get red {
    return create(red: maxRed);
  }

  /// Green color with full transparency.
  P get green {
    return create(green: maxGreen);
  }

  /// Blue color with full transparency.
  P get blue {
    return create(blue: maxBlue);
  }

  /// Yellow color with full transparency.
  P get yellow {
    return create(red: maxRed, green: maxGreen);
  }

  /// Cyan color with full transparency.
  P get cyan {
    return create(green: maxGreen, blue: maxBlue);
  }

  /// Magenta color with full transparency.
  P get magenta {
    return create(red: maxRed, blue: maxBlue);
  }

  /// Returns the red channel value of the [pixel].
  C getRed(P pixel);

  /// Returns the green channel value of the [pixel].
  C getGreen(P pixel);

  /// Returns the blue channel value of the [pixel].
  C getBlue(P pixel);

  @override
  P fromFloatRgba(Float32x4 pixel) {
    return copyWithNormalized(
      zero,
      red: pixel.x,
      green: pixel.y,
      blue: pixel.z,
    );
  }
}
