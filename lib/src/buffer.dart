import 'dart:typed_data';

import 'package:pxl/src/format.dart';
import 'package:pxl/src/geometry.dart';
import 'package:pxl/src/internal.dart';

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
  T getAt(Pos pos) => contains(pos) ? getAtUnsafe(pos) : format.zero;

  /// Returns the pixel at the given position **without bounds checking**.
  ///
  /// If outside the bounds of the buffer, the behavior is undefined.
  T getAtUnsafe(Pos pos);

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
    return _MapBuffer(
      this,
      (p) => format.convert(p, from: this.format),
      format,
    );
  }
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
  T getAtUnsafe(Pos pos) => _convert(_source.getAtUnsafe(pos));

  @override
  int get width => _source.width;

  @override
  int get height => _source.height;
}
