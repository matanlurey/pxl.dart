part of '../buffer.dart';

/// A 2-dimensional buffer of integer-based pixel data in memory.
///
/// Each pixel is represented by a single integer value, which typically stores
/// between 8 and 32 bits of data.
///
/// The default [format] is [abgr8888].
final class IntPixels extends Pixels<int> {
  /// Creates a new buffer of integer-based pixel data.
  ///
  /// Both [width] and [height] must be greater than zero.
  ///
  /// The [format] defaults to [abgr8888], and if [data] is provided it's
  /// contents must are assumed to be in the same format, and `data.length` must
  /// be equal to `width * height`.
  factory IntPixels(
    int width,
    int height, {
    PixelFormat<int, int> format = abgr8888,
    TypedDataList<int>? data,
  }) {
    if (width < 1) {
      throw ArgumentError.value(width, 'width', 'Must be greater than zero.');
    }
    if (height < 1) {
      throw ArgumentError.value(height, 'height', 'Must be greater than zero.');
    }
    if (data == null) {
      data = newIntBuffer(bytes: format.bytesPerPixel, length: width * height);
    } else {
      RangeError.checkValueInInterval(
        data.length,
        0,
        width * height,
        'data.length',
      );
    }
    return IntPixels._(
      data,
      width: width,
      height: height,
      format: format,
    );
  }

  const IntPixels._(
    this.data, {
    required super.width,
    required super.height,
    super.format = abgr8888,
  }) : assert(data.length > 0, 'Data must not be empty.');

  @override
  final TypedDataList<int> data;
}
