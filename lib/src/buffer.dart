import 'dart:typed_data';

import 'package:pxl/src/blend.dart';
import 'package:pxl/src/format.dart';
import 'package:pxl/src/geometry.dart';
import 'package:pxl/src/internal.dart';

part 'buffer/clipped.dart';
part 'buffer/indexed.dart';
part 'buffer/map.dart';
part 'buffer/pixels_float.dart';
part 'buffer/pixels_int.dart';
part 'buffer/pixels.dart';

/// A 2-dimensional _view_ of pixel data [T] in memory.
///
/// Buffer is analogous to a (read only) [Iterable] of pixels, but with a
/// 2-dimensional structure. It is used to represent pixel data in memory
/// without copying it, but also without exposing the raw memory.
///
/// In most cases buffers will be used ephemerally; [Pixels] is an actual
/// representation of pixel data.
abstract mixin class Buffer<T> {
  /// @nodoc
  const Buffer();

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

  /// Returns whether the buffer is empty.
  bool get isEmpty => length == 0;

  /// Returns whether the buffer is not empty.
  bool get isNotEmpty => length != 0;

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
  /// ## Example
  ///
  /// ```dart
  /// final buffer = FloatPixels(1, 3, data: Float32x4List.fromList([
  ///   floatRgba.red,
  ///   floatRgba.green,
  ///   floatRgba.blue,
  /// ]));
  ///
  /// final converted = buffer.mapConvert(abgr8888);
  /// print(converted.data); // [0xFFFF0000, 0xFF00FF00, 0xFF0000FF]
  /// ```
  Buffer<R> mapConvert<R>(PixelFormat<R, void> format) {
    if (identical(this.format, format)) {
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
  /// only contain pixels that are within the bounds of the original buffer; if
  /// the bounded rectangle is empty, the returned buffer will be empty.
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
  /// final clipped = buffer.mapClipped(Rect.fromLTWH(1, 1, 2, 2));
  /// print(clipped.data); // [0xFF00FF00, 0xFF0000FF]
  /// ```
  Buffer<T> mapClipped(Rect bounds) {
    return _ClippedBuffer(this, bounds.intersect(this.bounds));
  }

  /// Returns a lazy iterable of pixels in the buffer from [start] to [end].
  ///
  /// The returned iterable will contain all pixels in the buffer that are
  /// within the rectangle defined by [start] and [end], inclusive.
  ///
  /// The provided positions are clamped to the bounds of the buffer, and yield
  /// no pixels if `start > end`.
  Iterable<T> getRange(Pos start, Pos end) {
    final bottomRight = bounds.bottomRight;
    start = start.clamp(Pos.zero, bottomRight);
    end = end.clamp(Pos.zero, bottomRight);
    if (Pos.byRowMajor(start, end) > 0) {
      return const Iterable.empty();
    }
    return getRangeUnsafe(start, end);
  }

  /// Returns a lazy iterable of pixels in the buffer from [start] to [end].
  ///
  /// The returned iterable will contain all pixels in the buffer that are
  /// within the rectangle defined by [start] and [end], inclusive.
  ///
  /// The provided positions must be `(0, 0) <= start <= end < (width, height)`
  /// or the behavior is undefined.
  Iterable<T> getRangeUnsafe(Pos start, Pos end) {
    final iStart = start.y * width + start.x;
    final iEnd = end.y * width + end.x;
    return data.skip(iStart).take(iEnd - iStart + 1);
  }

  /// Returns a lazy iterable of pixels in the rectangle defined by [rect].
  ///
  /// The returned iterable will contain all pixels in the buffer that are
  /// within the rectangle defined by [rect].
  ///
  /// The provided rectangle is clamped to the bounds of the buffer and yields
  /// no pixels if the rectangle is empty.
  Iterable<T> getRect(Rect rect) => getRectUnsafe(rect.intersect(bounds));

  /// Returns a lazy iterable of pixels in the rectangle defined by [rect].
  ///
  /// The returned iterable will contain all pixels in the buffer that are
  /// within the rectangle defined by [rect].
  ///
  /// The provided rectangle must be contained within the bounds of the buffer
  /// or the behavior is undefined.
  Iterable<T> getRectUnsafe(Rect rect) {
    if (rect.width == width) {
      return getRangeUnsafe(rect.topLeft, rect.bottomRight - const Pos(1, 1));
    }
    return rect.positions.map(getUnsafe);
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

  @override
  T getUnsafe(Pos pos) => _source.getUnsafe(pos);
}
