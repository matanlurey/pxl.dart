part of '../buffer.dart';

/// A 2-dimensional buffer of pixel data in memory.
///
/// [Pixels] is a concrete representation of pixel data in memory, and is a
/// lightweight wrapper around the raw bytes represented by a [TypedDataList];
/// but cannot be extended or implemented (similar to [TypedDataList]).
///
/// In most cases either [IntPixels] or [Float32x4Pixels] will be used directly.
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
  P getAtUnsafe(Pos pos) => data[_indexAtUnsafe(pos)];

  /// Sets the pixel at the given position.
  ///
  /// If outside the bounds of the buffer, does nothing.
  void setAt(Pos pos, P pixel) {
    if (contains(pos)) {
      setAtUnsafe(pos, pixel);
    }
  }

  /// Sets the pixel at the given position **without bounds checking**.
  ///
  /// If outside the bounds of the buffer, the behavior is undefined.
  @unsafeNoBoundsChecks
  void setAtUnsafe(Pos pos, P pixel) {
    data[_indexAtUnsafe(pos)] = pixel;
  }

  /// Copies a rectangular region of pixels from [src] to [dst].
  ///
  /// The [width] and [height] default to the source buffer's dimensions, the
  /// [source] defaults to the entire source buffer, and the [destination]
  /// defaults to the top-left corner of the destination buffer, respectively.
  ///
  /// [blend] is the function used to blend the source and destination pixels,
  /// which defaults to replacing the destination pixel with the source pixel,
  /// regardless of the source pixel's alpha value.
  ///
  /// If the source dimensions are:
  ///
  /// - _larger_ than the destination dimensions, the excess pixels are ignored.
  /// - _the same buffer_, the behavior is undefined.
  ///
  /// If the format of the source and destination buffers are different,
  /// [PixelFormat.convert] is used.
  static void blit<S, T>(
    Buffer<S> src,
    Pixels<T> dst, {
    T Function(T, T)? blend,
    Rect? source,
    Pos? destination,
  }) {
    final Buffer<T> srcConverted;
    if (identical(src.format, dst.format)) {
      srcConverted = src as Buffer<T>;
    } else {
      srcConverted = src.mapConvert(dst.format);
    }

    final srcBounds = source ?? src.bounds;
    final dstBounds = Rect.fromLTWH(
      destination?.x ?? 0,
      destination?.y ?? 0,
      srcBounds.width,
      srcBounds.height,
    ).intersect(dst.bounds);

    for (var y = dstBounds.top; y < dstBounds.bottom; y++) {
      for (var x = dstBounds.left; x < dstBounds.right; x++) {
        final dstPos = Pos(x, y);
        final srcPos = dstPos - dstBounds.topLeft;
        var output = srcConverted.getAt(srcPos);
        if (blend != null) {
          output = blend(output, dst.getAt(dstPos));
        }
        dst.setAt(dstPos, output);
      }
    }
  }
}
