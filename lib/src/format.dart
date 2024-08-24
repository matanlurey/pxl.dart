import 'dart:typed_data';

import 'package:meta/meta.dart';

part 'format/abgr8888.dart';
part 'format/float_rgba.dart';
part 'format/indexed.dart';
part 'format/rgb.dart';
part 'format/rgba.dart';
part 'format/system8.dart';

/// Describes the organization and characteristics of pixel data [P] in memory.
///
/// A pixel format is essentially a set of rules and static-like methods that
/// define how to work with pixels of a specific format without requiring boxing
/// of pixels. Several built-in pixel formats are provided, such as [abgr8888]
/// and [floatRgba].
///
/// > [!TIP]
/// > While the API evolves, it is not possible to create custom pixel formats.
///
/// /// {@category Pixel Formats}
@immutable
abstract final class PixelFormat<P, C> {
  /// @nodoc
  const PixelFormat();

  /// Human-readable name or description of the pixel format.
  ///
  /// By convention, the name is in uppercase and uses underscores to separate
  /// words.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.name); // 'ABGR8888'
  /// print(floatRgba.name); // 'FLOAT_RGBA'
  /// ```
  String get name;

  /// Number of bytes required to store a single pixel in memory.
  int get bytesPerPixel;

  /// Returns the distance between two pixels in the pixel format.
  ///
  /// What constitutes distance is not defined by this method, and is up to the
  /// pixel format to define. For example, both [abgr8888] and [floatRgba] use
  /// cartesian distance to compare pixels.
  double distance(P a, P b);

  /// The zero, or minimum, value for the pixel format.
  ///
  /// This value typically represents transparent and/or empty (black) pixels.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.zero); // 0x00000000
  /// print(floatRgba.zero); // [0.0, 0.0, 0.0, 0.0]
  /// ```
  P get zero;

  /// The maximum value for the pixel format.
  ///
  /// This value typically represents opaque and/or full (white) pixels.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.max); // 0xFFFFFFFF
  /// print(floatRgba.max); // [1.0, 1.0, 1.0, 1.0]
  /// ```
  P get max;

  /// Clamps a [pixel] to the valid range of values for the pixel format.
  ///
  /// The operation does not have a canonical meaning; the only guarantee is
  /// that for a given pixel format, the result will be a valid pixel and will
  /// be idempotent and always return the same result for the same input.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.clamp(-1)); // 0xFFFFFFFF
  /// print(floatRgba.clamp(Float32x4(2.0, 2.0, 2.0, 2.0))); // [1.0, 1.0, 1.0, 1.0]
  /// ```
  P clamp(P pixel);

  /// Returns a copy of the [pixel].
  ///
  /// Subclasses override this method to provide named parameters for channels.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.copyWith(0x12345678, red: 0x9A)); // 0x9A345678
  /// print(floatRgba.copyWith(Float32x4(0.1, 0.2, 0.3, 0.4), red: 0.5)); // [0.5, 0.2, 0.3, 0.4]
  /// ```
  P copyWith(P pixel);

  /// Returns a copy of the [pixel] with normalized values.
  ///
  /// Subclasses override this method to provide named parameters for channels.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.copyWithNormalized(0x12345678, red: 1.0)); // 0xFF345678
  /// print(floatRgba.copyWithNormalized(Float32x4(0.1, 0.2, 0.3, 0.4), red: 0.5)); // [0.5, 0.2, 0.3, 0.4]
  /// ```
  P copyWithNormalized(P pixel);

  /// Converts a pixel in the [abgr8888] pixel format to `this` pixel format.
  ///
  /// ABGR8888 is used as the canonical integer-based pixel format, and this
  /// method guarantees that all pixel formats can be converted from it. Loss of
  /// precision may occur when converting from a higher-precision format.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(floatRgba.fromAbgr8888(abgr8888.red)); // [1.0, 0.0, 0.0, 1.0]
  /// print(floatRgba.fromAbgr8888(abgr8888.white)); // [1.0, 1.0, 1.0, 1.0]
  /// ```
  P fromAbgr8888(int pixel);

  /// Converts a pixel in `this` pixel format to the [abgr8888] pixel format.
  ///
  /// ABGR8888 is used as the canonical integer-based pixel format, and this
  /// method guarantees that all pixel formats can be converted to it. Loss of
  /// precision may occur when `this` pixel format has higher precision.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.toAbgr8888(floatRgba.red)); // 0xFFFF0000
  /// print(abgr8888.toAbgr8888(floatRgba.white)); // 0xFFFFFFFF
  /// ```
  int toAbgr8888(P pixel);

  /// Converts a pixel in the [floatRgba] pixel format to `this` pixel format.
  ///
  /// FLOAT_RGBA is used as the canonical floating-point pixel format, and this
  /// method guarantees that all pixel formats can be converted from it. Loss of
  /// precision may occur when converting from a higher-precision format.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(abgr8888.fromFloatRgba(floatRgba.red)); // 0xFFFF0000
  /// print(abgr8888.fromFloatRgba(floatRgba.white)); // 0xFFFFFFFF
  /// ```
  P fromFloatRgba(Float32x4 pixel);

  /// Converts a pixel in `this` pixel format to the [floatRgba] pixel format.
  ///
  /// FLOAT_RGBA is used as the canonical floating-point pixel format, and this
  /// method guarantees that all pixel formats can be converted to it. Loss of
  /// precision may occur when `this` pixel format has higher precision.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(floatRgba.toFloatRgba(abgr8888.red)); // [1.0, 0.0, 0.0, 1.0]
  /// print(floatRgba.toFloatRgba(abgr8888.white)); // [1.0, 1.0, 1.0, 1.0]
  /// ```
  Float32x4 toFloatRgba(P pixel);

  /// Converts a pixel [from] one another format _to_ `this` format.
  ///
  /// The default implementation of this method is to convert the pixel to
  /// either ABGR8888 or FLOAT_RGBA, and then convert it to `this` format;
  /// formats may override this method to provide more efficient conversions
  /// for popular conversions.
  P convert<R>(R pixel, {required PixelFormat<R, void> from}) {
    if (pixel is int) {
      return fromAbgr8888(from.toAbgr8888(pixel));
    }
    return fromFloatRgba(from.toFloatRgba(pixel));
  }

  @override
  String toString() => name;
}
