import 'package:pxl/pxl.dart';

import 'src/prelude.dart';

void main() {
  test('width must be at least 1', () {
    check(
      () => uncompressedPngEncoder.convert(_ZeroWidthBuffer()),
    ).throws<ArgumentError>();
  });

  test('height must be at least 1', () {
    check(
      () => uncompressedPngEncoder.convert(_ZeroHeightBuffer()),
    ).throws<ArgumentError>();
  });

  test('supports implicit pixel format conversion to abgr8888', () {
    final i1 = uncompressedPngEncoder.convert(
      IntPixels(1, 1)..fill(abgr8888.red),
    );
    final i2 = uncompressedPngEncoder.convert(
      IntPixels(1, 1, format: argb8888)..fill(argb8888.red),
    );

    check(i1).deepEquals(i2);
  });
}

final class _ZeroWidthBuffer extends Buffer<void> {
  @override
  int get width => 0;

  @override
  int get height => 1;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ZeroHeightBuffer extends Buffer<void> {
  @override
  int get width => 1;

  @override
  int get height => 0;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
