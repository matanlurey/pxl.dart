part of '../buffer.dart';

/// A 2-dimensional buffer of multi-channel floating point pixel data in memory.
///
/// Each pixel is represented by a [Float32x4] value, which is a 128-bit SIMD
/// compatible (on supported platforms) floating point vector, and typically
/// (but not necessarily) stores 4 floating point values in the range of 0.0 to
/// 1.0, which allows a higher dynamic range than the 8-bit integer based pixel
/// formats.
///
/// The default [format] is [floatRgba].
///
/// {@category Buffers}
final class FloatPixels extends Pixels<Float32x4> {
  /// Creates a new buffer of multi-channel floating point pixel data.
  ///
  /// Both [width] and [height] must be greater than zero.
  ///
  /// The [format] defaults to [floatRgba], and if [data] is provided it's
  /// contents must are assumed to be in the same format, and `data.length` must
  /// be equal to `width * height`.
  factory FloatPixels(
    int width,
    int height, {
    PixelFormat<Float32x4, void> format = floatRgba,
    Float32x4List? data,
  }) {
    if (width < 1) {
      throw ArgumentError.value(width, 'width', 'Must be greater than zero.');
    }
    if (height < 1) {
      throw ArgumentError.value(height, 'height', 'Must be greater than zero.');
    }
    if (data == null) {
      data = Float32x4List(width * height);
      if (format.zero.equal(Float32x4.zero()).signMask != 0) {
        data.fillRange(0, data.length, format.zero);
      }
    } else if (data.length != width * height) {
      throw RangeError.value(
        data.length,
        'data.length',
        'Must be equal to width * height.',
      );
    }
    return FloatPixels._(
      data,
      width: width,
      height: height,
      format: format,
    );
  }

  /// Creates a copy of the given buffer with the same pixel data and
  /// dimensions.
  ///
  /// The [format] and [data] is copied from the given buffer.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final original = FloatPixels(3, 3);
  /// final clipped = original.getRegion(Rect.fromLTWH(1, 1, 2, 2));
  ///
  /// final copy = FloatPixels.from(clipped);
  /// print(copy.width); // 2
  /// print(copy.height); // 2
  /// ```
  factory FloatPixels.from(Buffer<Float32x4> buffer) {
    final data = Float32x4List(buffer.length);
    data.setAll(0, buffer.data);
    return FloatPixels(
      buffer.width,
      buffer.height,
      data: data,
      format: buffer.format,
    );
  }

  const FloatPixels._(
    this.data, {
    required super.width,
    required super.height,
    super.format = floatRgba,
  }) : assert(data.length > 0, 'Data must not be empty.');

  @override
  final Float32x4List data;
}
