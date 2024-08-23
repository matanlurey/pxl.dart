part of '../buffer.dart';

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
