import 'dart:typed_data';

import 'package:lodim/lodim.dart' as lodim;
import 'package:pxl/src/blend.dart';
import 'package:pxl/src/format.dart';
import 'package:pxl/src/geometry.dart';
import 'package:pxl/src/internal.dart';

part 'buffer/clipped.dart';
part 'buffer/compare.dart';
part 'buffer/indexed.dart';
part 'buffer/map.dart';
part 'buffer/pixels_float.dart';
part 'buffer/pixels_int.dart';
part 'buffer/pixels.dart';
part 'buffer/scaled.dart';

/// A 2-dimensional _view_ of pixel data [T] in memory.
///
/// Buffer is analogous to a (read only) [Iterable] of pixels, but with a
/// 2-dimensional structure. It is used to represent pixel data in memory
/// without copying it, but also without exposing the raw memory.
///
/// In most cases buffers will be used ephemerally; [Pixels] is an actual
/// representation of pixel data.
///
/// {@category Buffers}
abstract base mixin class Buffer<T extends Object?> {
  /// Format of the pixel data in the buffer.
  PixelFormat<T, void> get format;

  /// Pixel data in the buffer.
  Iterable<T> get data;

  /// Width of the buffer in pixels.
  int get width;

  /// Height of the buffer in pixels.
  int get height;

  /// Length of the buffer in pixels.
  int get length => width * height;

  /// Returns whether the given position is within the bounds of the buffer.
  bool contains(Pos pos) => bounds.contains(pos);

  /// Returns the buffer as a bounding rectangle.
  ///
  /// The returned rectangle has the same dimensions as the buffer and is
  /// anchored at the origin (0, 0).
  Rect get bounds => Rect.fromLTWH(0, 0, width, height);

  /// Returns the pixel at the given position.
  ///
  /// If outside the bounds of the buffer, returns a suitable zero value.
  T get(Pos pos) => contains(pos) ? getUnsafe(pos) : format.zero;

  /// Returns the pixel at the given position **without bounds checking**.
  ///
  /// If outside the bounds of the buffer, the behavior is undefined.
  T getUnsafe(Pos pos);

  /// Compares the buffer to another buffer and returns the result.
  ComparisonResult<T> compare(Buffer<T> other, {double epsilon = 1e-10}) {
    return ComparisonResult._compare(this, other, epsilon: epsilon);
  }

  /// Returns a lazy buffer buffer that converts pixels with the given function.
  ///
  /// It is expected that the function does not change the representation of the
  /// pixel data, only the values. For example a function that inverts the red
  /// channel of an RGB pixel would be acceptable, but a function that converts
  /// an RGB pixel to an RGBA pixel would not; for that use [mapConvert]
  /// instead.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final buffer = IntPixels(1, 3, data: Uint32List.fromList([
  ///   abgr8888.red,
  ///   abgr8888.green,
  ///   abgr8888.blue,
  /// ]));
  ///
  /// // Invert the each pixel.
  /// final converted = buffer.map((pixel) => pixel ^ 0xFFFFFFFF);
  /// print(converted.data); // [0xFF00FFFF, 0xFF00FF00, 0xFF0000FF]
  /// ```
  Buffer<T> map(T Function(T) convert) {
    return _MapBuffer(this, convert, format);
  }

  /// Returns a lazy buffer that converts pixels with the given function.
  ///
  /// The function is called with the position of the pixel in the buffer.
  ///
  /// It is expected that the function does not change the representation of the
  /// pixel data, only the values. For example a function that inverts the red
  /// channel of an RGB pixel would be acceptable, but a function that converts
  /// an RGB pixel to an RGBA pixel would not; for that use [mapConvert]
  /// instead.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final buffer = IntPixels(2, 2, data: Uint32List.fromList([
  ///   abgr8888.red, abgr8888.green,
  ///   abgr8888.blue, abgr8888.alpha,
  /// ]));
  ///
  /// // Invert pixels in the top row.
  /// final converted = buffer.mapIndexed((pos, pixel) {
  ///   if (pos.y == 0) return pixel ^ 0xFFFFFFFF;
  ///   return pixel;
  /// });
  ///
  /// print(converted.data); // [0xFF00FFFF, 0xFF00FF00, 0xFF0000FF, 0xFF000000]
  /// ```
  Buffer<T> mapIndexed(T Function(Pos, T) convert) {
    return _MapIndexedBuffer(this, convert);
  }

  /// Returns a lazy buffer that converts pixels to the given [format].
  ///
  /// If `this.format == format`, the buffer is returned as-is.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final buffer = Float32x4Pixels(1, 3, data: Float32x4List.fromList([
  ///   floatRgba.red,
  ///   floatRgba.green,
  ///   floatRgba.blue,
  /// ]));
  ///
  /// final converted = buffer.mapConvert(abgr8888);
  /// print(converted.data); // [0xFFFF0000, 0xFF00FF00, 0xFF0000FF]
  /// ```
  Buffer<R> mapConvert<R>(PixelFormat<R, void> format) {
    if (format == this.format) {
      return this as Buffer<R>;
    }
    return _MapBuffer(
      this,
      (p) => format.convert(p, from: this.format),
      format,
    );
  }

  /// Returns a lazy buffer that clips the buffer to the given [bounds].
  ///
  /// The returned buffer will have the same dimensions as the bounds, and will
  /// only contain pixels that are within the bounds of the original buffer; the
  /// resulting buffer must not be empty.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final buffer = IntPixels(3, 3, data: Uint32List.fromList([
  ///   abgr8888.red, abgr8888.green, abgr8888.blue,
  ///   abgr8888.red, abgr8888.green, abgr8888.blue,
  ///   abgr8888.red, abgr8888.green, abgr8888.blue,
  /// ]));
  ///
  /// final clipped = buffer.mapRect(Rect.fromLTWH(1, 1, 2, 2));
  /// print(clipped.data); // [0xFF00FF00, 0xFF0000FF]
  /// ```
  Buffer<T> mapRect(Rect bounds) {
    final result = bounds.intersect(this.bounds);
    if (result.isEmpty) {
      throw ArgumentError.value(bounds, 'bounds', 'region must be non-empty');
    }
    return _ClippedBuffer(this, result);
  }

  /// Returns a lazy buffer that scales the buffer by the given factor.
  ///
  /// The returned buffer will have the same dimensions as the original buffer
  /// multiplied by the scale factor. The scale factor must be greater than 0.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final buffer = IntPixels(2, 2, data: Uint32List.fromList([
  ///   abgr8888.red, abgr8888.green,
  ///   abgr8888.blue, abgr8888.magenta,
  /// ]));
  ///
  /// final scaled = buffer.mapScaled(2);
  /// print(scaled.data); // [0xFFFF0000, 0xFFFF0000, 0xFF00FF00, 0xFF00FF00, 0xFF0000FF, 0xFF0000FF, 0xFFFF00FF, 0xFFFF00FF]
  /// ```
  Buffer<T> mapScaled(int scale) {
    RangeError.checkNotNegative(scale, 'scale');
    if (scale == 1) {
      return this;
    }
    return _ScaledBuffer(this, scale);
  }

  /// Returns a lazy iterable of pixels in the rectangle defined by [rect].
  ///
  /// The returned iterable will contain all pixels in the buffer that are
  /// within the rectangle defined by [rect].
  ///
  /// The provided rectangle is clamped to the bounds of the buffer and yields
  /// no pixels if the rectangle is empty.
  Iterable<T> getRect(Rect rect) {
    return getRectUnsafe(rect.intersect(bounds));
  }

  /// Returns a lazy iterable of pixels in the rectangle defined by [rect].
  ///
  /// The returned iterable will contain all pixels in the buffer that are
  /// within the rectangle defined by [rect].
  ///
  /// The provided rectangle must be contained within the bounds of the buffer
  /// or the behavior is undefined.
  Iterable<T> getRectUnsafe(Rect rect) {
    return lodim.getRect(rect, getUnsafe);
  }

  @override
  String toString() => bufferToLongString(this);

  String get _typeName => 'Buffer';

  /// Converts a [Buffer] to a string like [Buffer.toString].
  ///
  /// The string will be long and detailed, suitable for debugging, and even if
  /// the dimensions of the buffer are large, the buffer will not be truncated,
  /// which may result in a very long string for large buffers.
  static String bufferToLongString<T>(Buffer<T> buffer) {
    return _bufferToStringImpl(buffer);
  }

  static String _bufferToStringImpl<T>(Buffer<T> buffer) {
    final output = StringBuffer('${buffer._typeName} {\n');
    output.writeln('  width: ${buffer.width},');
    output.writeln('  height: ${buffer.height},');
    output.writeln('  format: ${buffer.format},');
    output.writeln('  data: (${buffer.length}) [');

    for (var y = 0; y < buffer.height; y++) {
      output.write('    ');
      for (var x = 0; x < buffer.width; x++) {
        output.write(buffer.format.describe(buffer.getUnsafe(Pos(x, y))));
        if (x < buffer.width - 1) {
          output.write(', ');
        }
      }
      output.writeln(',');
    }

    output.writeln('  ]');
    output.write('}');
    return output.toString();
  }
}

abstract final class _Buffer<T> with Buffer<T> {
  const _Buffer(this._source);
  final Buffer<T> _source;

  @override
  PixelFormat<T, void> get format => _source.format;

  @override
  Iterable<T> get data;

  @override
  int get width => _source.width;

  @override
  int get height => _source.height;
}
