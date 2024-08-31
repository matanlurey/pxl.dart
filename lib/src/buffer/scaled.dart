part of '../buffer.dart';

final class _ScaledBuffer<T> extends _Buffer<T> {
  const _ScaledBuffer(super._source, this._scale);
  final int _scale;

  @override
  Iterable<T> get data {
    return Iterable.generate(length, (i) {
      final pos = Pos(i % width, i ~/ width);
      return getUnsafe(pos);
    });
  }

  @override
  T getUnsafe(Pos pos) {
    final sourcePos = pos ~/ _scale;
    return _source.getUnsafe(sourcePos);
  }

  @override
  int get width => _source.width * _scale;

  @override
  int get height => _source.height * _scale;
}
