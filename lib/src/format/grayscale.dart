part of '../format.dart';

/// A mixin for pixel formats that represent _graysacle_ pixels.
base mixin Grayscale<P, C> implements PixelFormat<P, C> {
  /// Creates a new pixel with the given channel values.
  ///
  /// The [gray] value is optional.
  ///
  /// If omitted, the channel value is set to the minimum value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Creating a full gray pixel.
  /// final pixel = grayscale.create(gray: 0xFF);
  /// ```
  P create({C? gray}) => copyWith(zero, gray: gray ?? minGray);

  @override
  P copyWith(P pixel, {C? gray});

  /// Creates a new pixel with the given channel value normalized to the range
  /// `[0.0, 1.0]`.
  ///
  /// The [gray] value is optional.
  ///
  /// If omitted, the channel value is set to `0.0`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Creating a full gray pixel.
  /// final pixel = grayscale.createNormalized(gray: 1.0);
  /// ```
  P createNormalized({double gray = 0.0}) {
    return copyWithNormalized(zero, gray: gray);
  }

  @override
  P copyWithNormalized(P pixel, {double? gray});

  /// The minimum value for the gray channel.
  C get minGray;

  /// The maximum value for the gray channel.
  C get maxGray;

  /// Black pixel.
  P get black;

  /// White pixel.
  P get white => max;

  /// Returns the gray channel value of the [pixel].
  C getGray(P pixel);

  @override
  P fromFloatRgba(Float32x4 pixel) {
    final (g, _) = _luminanceFloatRgba(pixel);
    return createNormalized(gray: g);
  }
}

abstract final class _GrayInt extends PixelFormat<int, int>
    with Grayscale<int, int> {
  const _GrayInt();

  @override
  double distance(int a, int b) => (a - b).abs().toDouble();

  @override
  double compare(int a, int b) => 1.0 - (a - b).abs() / maxGray.toDouble();

  @override
  @nonVirtual
  int get zero => 0x0;

  @override
  @nonVirtual
  int get minGray => 0x0;

  @override
  @nonVirtual
  int clamp(int pixel) => pixel & max;

  @override
  int get black => create(gray: minGray);
}
