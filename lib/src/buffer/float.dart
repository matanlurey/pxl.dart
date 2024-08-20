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
final class Float32x4Pixels extends Pixels<Float32x4> {
  /// Creates a new buffer of multi-channel floating point pixel data.
  ///
  /// Both [width] and [height] must be greater than zero.
  ///
  /// The [format] defaults to [floatRgba], and if [data] is provided it's
  /// contents must are assumed to be in the same format, and `data.length` must
  /// be equal to `width * height`.
  factory Float32x4Pixels(
    int width,
    int height, {
    PixelFormat<Float32x4, double> format = floatRgba,
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
    } else {
      RangeError.checkValueInInterval(
        data.length,
        0,
        width * height,
        'data.length',
      );
    }
    return Float32x4Pixels._(
      data,
      width: width,
      height: height,
      format: format,
    );
  }

  const Float32x4Pixels._(
    this.data, {
    required super.width,
    required super.height,
    super.format = floatRgba,
  }) : assert(data.length > 0, 'Data must not be empty.');

  @override
  final Float32x4List data;
}
