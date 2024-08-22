part of '../buffer.dart';

/// A 2-dimensional buffer of pixel data in memory.
///
/// [Pixels] is a concrete representation of pixel data in memory, and is a
/// lightweight wrapper around the raw bytes represented by a [TypedDataList];
/// but cannot be extended or implemented (similar to [TypedDataList]).
///
/// In most cases either [IntPixels] or [FloatPixels] will be used directly.
abstract final class Pixels<P> with Buffer<P> {
  /// @nodoc
  const Pixels({
    required this.format,
    required this.width,
    required this.height,
  })  : assert(width > 0, 'Width must be greater than zero.'),
        assert(height > 0, 'Height must be greater than zero.');

  /// Raw bytes of pixel data.
  ///
  /// This type is exposed for operations that require direct access to the
  /// underlying memory, such as [copying pixel data to a canvas][1], or
  /// [transferring bytes to an isolate][2]; in most cases the other methods
  /// provided by [Pixels] will be used instead.
  ///
  /// [1]: https://pub.dev/documentation/web/latest/web/ImageData/ImageData.html
  /// [2]: https://api.dart.dev/stable/3.5.1/dart-isolate/TransferableTypedData-class.html
  @override
  TypedDataList<P> get data;

  @override
  final PixelFormat<P, void> format;

  @override
  final int width;

  @override
  final int height;

  int _indexAtUnsafe(Pos pos) => pos.y * width + pos.x;

  @override
  @unsafeNoBoundsChecks
  P getUnsafe(Pos pos) => data[_indexAtUnsafe(pos)];

  /// Sets the pixel at the given position.
  ///
  /// If outside the bounds of the buffer, does nothing.
  void set(Pos pos, P pixel) {
    if (contains(pos)) {
      setUnsafe(pos, pixel);
    }
  }

  /// Sets the pixel at the given position **without bounds checking**.
  ///
  /// If outside the bounds of the buffer, the behavior is undefined.
  @unsafeNoBoundsChecks
  void setUnsafe(Pos pos, P pixel) {
    data[_indexAtUnsafe(pos)] = pixel;
  }

  /// Clears the buffer to the [PixelFormat.zero] value.
  ///
  /// This is equivalent to calling [fill] with the zero value of the format.
  ///
  /// If a [target] rectangle is provided, only the pixels within that rectangle
  /// will be cleared, and the rectangle will be clipped to the bounds of the
  /// buffer. If omitted, the entire buffer will be cleared.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pixels = IntPixels(2, 2);
  /// pixels.clear();
  /// pixels.clear(Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void clear([Rect? target]) {
    fill(format.zero, target);
  }

  /// Clears the buffer to the [PixelFormat.zero] value.
  ///
  /// This is equivalent to calling [fillUnsafe] with the zero value of the
  /// format.
  ///
  /// If a [target] rectangle is provided, only the pixels within that rectangle
  /// will be cleared. If the rectangle is outside the bounds of the buffer, the
  /// behavior is undefined.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pixels = IntPixels(2, 2);
  /// pixels.clearUnsafe();
  /// pixels.clearUnsafe(Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void clearUnsafe([Rect? target]) {
    fillUnsafe(format.zero, target);
  }

  /// Fill the buffer with the given pixel.
  ///
  /// This is equivalent to calling [set] for every pixel in the buffer.
  ///
  /// If a [target] rectangle is provided, only the pixels within that rectangle
  /// will be filled, and the rectangle will be clipped to the bounds of the
  /// buffer. If omitted, the entire buffer will be filled.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pixels = IntPixels(2, 2);
  /// pixels.fill(0xFFFFFFFF);
  /// pixels.fill(0x00000000, Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void fill(P pixel, [Rect? target]) {
    if (target != null) {
      target = target.intersect(bounds);
    }
    return fillUnsafe(pixel, target);
  }

  /// Fill the buffer with the given pixel **without bounds checking**.
  ///
  /// This is equivalent to calling [setUnsafe] for every pixel in the buffer.
  ///
  /// If a [target] rectangle is provided, only the pixels within that rectangle
  /// will be filled. If the rectangle is outside the bounds of the buffer, the
  /// behavior is undefined.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pixels = IntPixels(2, 2);
  /// pixels.fillUnsafe(0xFFFFFFFF);
  /// pixels.fillUnsafe(0x00000000, Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void fillUnsafe(P pixel, [Rect? target]) {
    if (target == null) {
      return data.fillRange(
        0,
        data.length,
        pixel,
      );
    }
    if (target.width == width) {
      return data.fillRange(
        target.top * width,
        target.bottom * width,
        pixel,
      );
    }
    for (var y = target.top; y < target.bottom; y++) {
      final x = y * width;
      data.fillRange(
        x + target.left,
        x + target.right,
        pixel,
      );
    }
  }
}
