part of '../buffer.dart';

final class _ClippedBuffer<T> extends _Buffer<T> {
  const _ClippedBuffer(super._source, this._bounds);
  final Rect _bounds;

  @override
  Iterable<T> get data => _source.getRect(_bounds);

  @override
  T getUnsafe(Pos pos) => _source.getUnsafe(pos + _bounds.topLeft);

  @override
  int get width => _bounds.width;

  @override
  int get height => _bounds.height;
}
