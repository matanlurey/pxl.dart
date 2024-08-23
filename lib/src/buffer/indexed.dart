part of '../buffer.dart';

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
