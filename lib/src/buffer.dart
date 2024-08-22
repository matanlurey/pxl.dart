import 'dart:typed_data';

import 'package:pxl/src/format.dart';
import 'package:pxl/src/geometry.dart';
import 'package:pxl/src/internal.dart';

part 'buffer/blit_ops.dart';
part 'buffer/float.dart';
part 'buffer/int.dart';
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
  /// final clipped = buffer.getRegion(Rect.fromLTWH(1, 1, 2, 2));
  /// print(clipped.data); // [0xFF00FF00, 0xFF0000FF]
  /// ```
  Buffer<T> getRegion(Rect bounds) {
    return _ClippedBuffer(this, bounds.intersect(this.bounds));
  }
}

abstract final class _Buffer<T> with Buffer<T> {
  const _Buffer(this._source);
  final Buffer<T> _source;

  @override
  PixelFormat<T, void> get format => _source.format;

  @override
  Iterable<T> get data => _source.data;

  @override
  int get width => _source.width;

  @override
  int get height => _source.height;

  @override
  T getUnsafe(Pos pos) => _source.getUnsafe(pos);
}

final class _MapBuffer<S, T> with Buffer<T> {
  const _MapBuffer(this._source, this._convert, this.format);
  final Buffer<S> _source;
  final T Function(S) _convert;

  @override
  final PixelFormat<T, void> format;

  @override
  Iterable<T> get data => _source.data.map(_convert);

  @override
  T getUnsafe(Pos pos) => _convert(_source.getUnsafe(pos));

  @override
  int get width => _source.width;

  @override
  int get height => _source.height;
}

final class _MapIndexedBuffer<T> extends _Buffer<T> {
  const _MapIndexedBuffer(super._source, this._convert);
  final T Function(Pos, T) _convert;

  @override
  Iterable<T> get data {
    return Iterable.generate(length, (i) {
      final pos = Pos(i ~/ width, i % width);
      return getUnsafe(pos);
    });
  }

  @override
  T getUnsafe(Pos pos) => _convert(pos, _source.getUnsafe(pos));
}

final class _ClippedBuffer<T> extends _Buffer<T> {
  const _ClippedBuffer(super._source, this._bounds);
  final Rect _bounds;

  @override
  Iterable<T> get data => _bounds.positions.map(getUnsafe);

  @override
  T getUnsafe(Pos pos) => _source.getUnsafe(pos + _bounds.topLeft);

  @override
  int get width => _bounds.width;

  @override
  int get height => _bounds.height;
}
