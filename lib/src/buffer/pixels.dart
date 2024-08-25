part of '../buffer.dart';

/// A 2-dimensional buffer of pixel data in memory.
///
/// [Pixels] is a concrete representation of pixel data in memory, and is a
/// lightweight wrapper around the raw bytes represented by a [TypedDataList];
/// but cannot be extended or implemented (similar to [TypedDataList]).
///
/// In most cases either [IntPixels] or [FloatPixels] will be used directly.
///
/// {@category Buffers}
/// {@category Blending}
abstract final class Pixels<T> with Buffer<T> {
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
  TypedDataList<T> get data;

  @override
  final PixelFormat<T, void> format;

  @override
  final int width;

  @override
  final int height;

  int _indexAtUnsafe(Pos pos) => pos.y * width + pos.x;

  @override
  @unsafeNoBoundsChecks
  T getUnsafe(Pos pos) => data[_indexAtUnsafe(pos)];

  /// Sets the pixel at the given position.
  ///
  /// If outside the bounds of the buffer, does nothing.
  void set(Pos pos, T pixel) {
    if (contains(pos)) {
      setUnsafe(pos, pixel);
    }
  }

  /// Sets the pixel at the given position **without bounds checking**.
  ///
  /// If outside the bounds of the buffer, the behavior is undefined.
  @unsafeNoBoundsChecks
  void setUnsafe(Pos pos, T pixel) {
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
  /// pixels.clear(target: Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void clear({Rect? target}) {
    fill(format.zero, target: target);
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
  /// pixels.clearUnsafe(target: Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  @unsafeNoBoundsChecks
  void clearUnsafe({Rect? target}) {
    fillUnsafe(format.zero, target: target);
  }

  /// Fill the buffer with the given [pixel].
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
  /// pixels.fill(0x00000000, target: Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void fill(T pixel, {Rect? target}) {
    if (target != null) {
      target = target.intersect(bounds);
    }
    return fillUnsafe(pixel, target: target);
  }

  /// Fill the buffer with the given [pixel].
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
  /// pixels.fillUnsafe(0x00000000, target: Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  @unsafeNoBoundsChecks
  void fillUnsafe(T pixel, {Rect? target}) {
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

  /// Fill the buffer with the given [pixels].
  ///
  /// If a [target] rectangle is provided, only the pixels within that rectangle
  /// are filled, and the rectangle will be clipped to the bounds of the buffer.
  ///
  /// If the number of pixels in the iterable is less than the number of pixels
  /// in the target rectangle, the remaining pixels will be filled with the zero
  /// value of the format. If the number of pixels is greater, the extra pixels
  /// will be ignored.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pixels = IntPixels(2, 2);
  /// pixels.fillWith([0xFFFFFFFF, 0x00000000]);
  /// pixels.fillWith([0x00000000, 0xFFFFFFFF], target: Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  void fillWith(
    Iterable<T> pixels, {
    Rect? target,
  }) {
    if (target == null) {
      target = bounds;
    } else {
      target = target.intersect(bounds);
    }
    if (pixels.length < target.area) {
      pixels = pixels.followedBy(
        Iterable.generate(
          target.area - pixels.length,
          (_) => format.zero,
        ),
      );
    }
    return fillWithUnsafe(pixels, target: target);
  }

  /// Fill the buffer with the given [pixels].
  ///
  /// If a [target] rectangle is provided, only the pixels within that rectangle
  /// are filled. If the rectangle is outside the bounds of the buffer, the
  /// behavior is undefined.
  ///
  /// If the number of pixels in the iterable is less than the number of pixels
  /// in the target rectangle, or if the number of pixels is greater, the
  /// behavior is undefined.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pixels = IntPixels(2, 2);
  /// pixels.fillWithUnsafe([0xFFFFFFFF, 0x00000000]);
  /// pixels.fillWithUnsafe([0x00000000, 0xFFFFFFFF], target: Rect.fromLTWH(1, 0, 1, 2));
  /// ```
  @unsafeNoBoundsChecks
  void fillWithUnsafe(
    Iterable<T> pixels, {
    Rect? target,
  }) {
    if (target == null) {
      return data.setAll(0, pixels);
    }
    var skip = 0;
    for (var y = target.top; y < target.bottom; y++) {
      final x = y * width;
      data.setRange(
        x + target.left,
        x + target.right,
        pixels.skip(skip),
      );
      skip += target.width;
    }
  }

  @override
  Iterable<T> getRangeUnsafe(Pos start, Pos end) {
    final s = _indexAtUnsafe(start);
    final e = _indexAtUnsafe(end);
    return data.getRange(s, e + 1);
  }

  @override
  Iterable<T> getRectUnsafe(Rect rect) {
    if (rect.width == width) {
      return getRangeUnsafe(rect.topLeft, rect.bottomRight);
    }
    return _PixelsRectIterable(data, rect);
  }

  /// Copies the pixel data from a source buffer to `this` buffer.
  ///
  /// If a [source] rectangle is provided, only the pixels within that rectangle
  /// are copied, and the rectangle will be clipped to the bounds of the source
  /// buffer. If omitted, the entire source buffer will be copied.
  ///
  /// If a [target] position is provded, the top-left corner of the source
  /// rectangle will be copied starting at that position. If omitted, the
  /// top-left corner of the source rectangle will be copied to the top-left
  /// corner of the `this` buffer. If there is not sufficient space in the
  /// target buffer, the source rectangle will be clipped to fit `this`.
  ///
  /// The pixels are copied as-is, **without any conversion or blending**; see
  /// [blit] for converting and blending pixel data.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final src = IntPixels(2, 2, data: Uint32List.fromList([
  ///   0xFFFFFFFF, 0x00000000, //
  ///   0x00000000, 0xFFFFFFFF, //
  /// ]));
  ///
  /// final dst = IntPixels(3, 3);
  /// dst.copyFrom(src);
  /// dst.copyFrom(src, source: Rect.fromLTWH(1, 0, 1, 2));
  /// dst.copyFrom(src, target: Pos(1, 1));
  /// dst.copyFrom(src, source: Rect.fromLTWH(1, 0, 1, 2), target: Pos(1, 1));
  /// ```
  void copyFrom(
    Buffer<T> from, {
    Rect? source,
    Pos? target,
  }) {
    if (source == null) {
      if (target == null) {
        return copyFromUnsafe(from);
      }
      source = from.bounds;
    } else {
      source = source.intersect(from.bounds);
    }
    target ??= Pos.zero;
    final clipped = Rect.fromTLBR(
      target,
      target + source.size,
    ).intersect(bounds);
    if (clipped.isEmpty) {
      return;
    }
    source = Rect.fromLTWH(
      source.top,
      source.left,
      clipped.width,
      clipped.height,
    );
    return copyFromUnsafe(from, source: source, target: target);
  }

  /// Copies the pixel data from a source buffer to `this` buffer.
  ///
  /// If a [source] rectangle is provided, only the pixels within that rectangle
  /// are copied. If the rectangle is outside the bounds of the source buffer,
  /// the behavior is undefined.
  ///
  /// If a [target] position is provded, the top-left corner of the source
  /// rectangle will be copied starting at that position. If there is not
  /// sufficient space in the target buffer, the behavior is undefined.
  ///
  /// The pixels are copied as-is, **without any conversion or blending**; see
  /// [blit] for converting and blending pixel data.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final src = IntPixels(2, 2, data: Uint32List.fromList([
  ///   0xFFFFFFFF, 0x00000000, //
  ///   0x00000000, 0xFFFFFFFF, //
  /// ]));
  ///
  /// final dst = IntPixels(3, 3);
  /// dst.copyFromUnsafe(src);
  /// dst.copyFromUnsafe(src, source: Rect.fromLTWH(1, 0, 1, 2));
  /// dst.copyFromUnsafe(src, target: Pos(1, 1));
  /// dst.copyFromUnsafe(src, source: Rect.fromLTWH(1, 0, 1, 2), target: Pos(1, 1));
  /// ```
  @unsafeNoBoundsChecks
  void copyFromUnsafe(
    Buffer<T> from, {
    Rect? source,
    Pos? target,
  }) {
    if (from is Pixels<T>) {
      _copyFromUnsafeFast(from, source: source, target: target);
    } else {
      _copyFromUnsafeSlow(from, source: source, target: target);
    }
  }

  void _copyFromUnsafeSlow(
    Buffer<T> from, {
    Rect? source,
    Pos? target,
  }) {
    // Use the slow path if the source is not a framebuffer.
    final pixels = source == null ? from.data : from.getRectUnsafe(source);
    fillWithUnsafe(
      pixels,
      target: target == null
          ? null
          : Rect.fromTLBR(
              target,
              target + from.bounds.size - const Pos(1, 1),
            ),
    );
  }

  void _copyFromUnsafeFast(
    Pixels<T> from, {
    Rect? source,
    Pos? target,
  }) {
    // Use the fast path if the source is a framebuffer.
    if (source == null) {
      final index = target == null ? 0 : _indexAtUnsafe(target);
      return data.setAll(index, from.data);
    }

    // Use multiple setRange calls if the source is a framebuffer.
    target ??= Pos.zero;
    final src = from.data;
    final dst = this.data;
    var srcIdx = from._indexAtUnsafe(source.topLeft);
    var dstIdx = _indexAtUnsafe(target);
    for (var y = source.top; y < source.bottom; y++) {
      dst.setRange(
        dstIdx,
        dstIdx + source.width,
        src.getRange(srcIdx, srcIdx + source.width),
      );
      srcIdx += from.width;
      dstIdx += width;
    }
  }

  /// Blits, or copies with blending, the pixel data from a source buffer to
  /// `this` buffer.
  ///
  /// If a [source] rectangle is provided, only the pixels within that rectangle
  /// are copied, and the rectangle will be clipped to the bounds of the source
  /// buffer. If omitted, the entire source buffer will be copied.
  ///
  /// If a [target] position is provided, the top-left corner of the source
  /// rectangle will be copied starting at that position. If omitted, the
  /// top-left corner of the source rectangle will be copied to the top-left
  /// corner of the `this` buffer. If there is not sufficient space in the
  /// target buffer, the source rectangle will be clipped to fit `this`.
  ///
  /// If a [blend] mode is provided, the pixels will be blended using that mode.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final src = IntPixels(2, 2, data: Uint32List.fromList([
  ///   0xFFFFFFFF, 0x00000000, //
  ///   0x00000000, 0xFFFFFFFF, //
  /// ]));
  ///
  /// final dst = IntPixels(3, 3);
  /// dst.blit(src);
  /// dst.blit(src, source: Rect.fromLTWH(1, 0, 1, 2));
  /// dst.blit(src, target: Pos(1, 1));
  /// dst.blit(src, source: Rect.fromLTWH(1, 0, 1, 2), target: Pos(1, 1));
  /// ```
  void blit<S>(
    Buffer<S> from, {
    Rect? source,
    Pos? target,
    BlendMode blend = BlendMode.srcOver,
  }) {
    if (source == null) {
      if (target == null) {
        return blitUnsafe(from, blend: blend);
      }
      source = from.bounds;
    } else {
      source = source.intersect(from.bounds);
    }
    target ??= Pos.zero;
    final clipped = Rect.fromTLBR(
      target,
      target + source.size,
    ).intersect(bounds);
    if (clipped.isEmpty) {
      return;
    }
    source = Rect.fromLTWH(
      source.top,
      source.left,
      clipped.width,
      clipped.height,
    );
    return blitUnsafe(from, source: source, target: target, blend: blend);
  }

  /// Blits, or copies with blending, the pixel data from a source buffer to
  /// `this` buffer.
  ///
  /// If a [source] rectangle is provided, only the pixels within that rectangle
  /// are copied. If the rectangle is outside the bounds of the source buffer,
  /// the behavior is undefined.
  ///
  /// If a [target] position is provided, the top-left corner of the source
  /// rectangle will be copied starting at that position. If there is not
  /// sufficient space in the target buffer, the behavior is undefined.
  ///
  /// If a [blend] mode is provided, the pixels will be blended using that mode.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final src = IntPixels(2, 2, data: Uint32List.fromList([
  ///   0xFFFFFFFF, 0x00000000, //
  ///   0x00000000, 0xFFFFFFFF, //
  /// ]));
  ///
  /// final dst = IntPixels(3, 3);
  /// dst.blitUnsafe(src);
  /// dst.blitUnsafe(src, source: Rect.fromLTWH(1, 0, 1, 2));
  /// dst.blitUnsafe(src, target: Pos(1, 1));
  /// dst.blitUnsafe(src, source: Rect.fromLTWH(1, 0, 1, 2), target: Pos(1, 1));
  /// ```
  void blitUnsafe<S>(
    Buffer<S> from, {
    Rect? source,
    Pos? target,
    BlendMode blend = BlendMode.srcOver,
  }) {
    target ??= Pos.zero;
    final sRect = source ?? from.bounds;
    final tRect = Rect.fromTLBR(
      target,
      target + sRect.size,
    ).intersect(bounds);
    if (tRect.isEmpty) {
      return;
    }
    source = Rect.fromLTWH(
      sRect.top,
      sRect.left,
      tRect.width,
      tRect.height,
    );
    final fn = blend.getBlend(from.format, format);
    if (from is Pixels<S>) {
      _blitUnsafeFast(from, source: source, target: tRect, blend: fn);
    } else {
      _blitUnsafeSlow(from, source: source, target: tRect, blend: fn);
    }
  }

  void _blitUnsafeSlow<S>(
    Buffer<S> from, {
    required T Function(S src, T dst) blend,
    required Rect source,
    required Rect target,
  }) {
    final src = source.positions.iterator;
    final dst = target.positions.iterator;
    while (src.moveNext() && dst.moveNext()) {
      setUnsafe(
        dst.current,
        blend(
          from.getUnsafe(src.current),
          getUnsafe(dst.current),
        ),
      );
    }
  }

  void _blitUnsafeFast<S>(
    Pixels<S> from, {
    required T Function(S src, T dst) blend,
    required Rect source,
    required Rect target,
  }) {
    final src = from.data;
    final dst = this.data;
    var srcIdx = from._indexAtUnsafe(source.topLeft);
    var dstIdx = _indexAtUnsafe(target.topLeft);
    for (var y = source.top; y < source.bottom; y++) {
      for (var x = source.left; x < source.right; x++) {
        dst[dstIdx] = blend(src[srcIdx], dst[dstIdx]);
        srcIdx++;
        dstIdx++;
      }
      dstIdx += width - source.width;
    }
  }
}

final class _PixelsRectIterable<T> extends Iterable<T> {
  const _PixelsRectIterable(this._data, this._bounds);
  final TypedDataList<T> _data;
  final Rect _bounds;

  @override
  int get length => _bounds.area;

  @override
  Iterator<T> get iterator {
    final startIdx = _bounds.top * _bounds.width + _bounds.left;
    final endIdx = (_bounds.bottom - 1) * _bounds.width + _bounds.right - 1;
    return _PixelsRectIterator(_data, _bounds, startIdx - 1, endIdx);
  }
}

final class _PixelsRectIterator<T> implements Iterator<T> {
  _PixelsRectIterator(this._data, this._bounds, this._start, this._end);
  final TypedDataList<T> _data;
  final Rect _bounds;
  final int _end;

  int _start;

  @override
  @unsafeNoBoundsChecks
  T get current => _data[_start];

  @override
  bool moveNext() {
    // Imagine we are at B, in the rectangle {B, C, F, G}
    // B -> C -> F -> G
    //
    // A B C D
    // E F G H
    // I J K L
    //
    // If we are at the end of the row, move to the next row
    _start++;
    if (_start % _bounds.width == _bounds.right) {
      _start += _bounds.width - _bounds.width;
    }
    return _start <= _end;
  }
}
