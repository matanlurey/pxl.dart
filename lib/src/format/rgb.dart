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

  /// Creates a new pixel with the given channel values normalized to the range
  /// `[0.0, 1.0]`.
  ///
  /// The [red], [green], and [blue] values are optional.
  ///
  /// If omitted, the corresponding channel value is set to `0.0`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Creating a full red pixel.
  /// final pixel = rgb.createNormalized(red: 1.0);
  /// ```
  P createNormalized({
    double red = 0.0,
    double green = 0.0,
    double blue = 0.0,
  }) {
    return copyWithNormalized(
      zero,
      red: red,
      green: green,
      blue: blue,
    );
  }

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
}

base mixin _Rgb8Int on Rgb<int, int> {
  @override
  @nonVirtual
  double compare(int a, int b) => distance(a, b) / max;

  @override
  @nonVirtual
  int clamp(int pixel) => pixel & max;

  @override
  @nonVirtual
  int get zero => 0x0;

  @override
  @nonVirtual
  int get minRed => 0x00;

  @override
  @nonVirtual
  int get minGreen => 0x00;

  @override
  @nonVirtual
  int get minBlue => 0x00;

  @override
  @nonVirtual
  int get maxRed => 0xFF;

  @override
  @nonVirtual
  int get maxGreen => 0xFF;

  @override
  @nonVirtual
  int get maxBlue => 0xFF;

  @override
  String describe(int pixel) {
    return '0x${pixel.toRadixString(16).padLeft(max.bitLength ~/ 4, '0')}';
  }
}
