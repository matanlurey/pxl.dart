import 'dart:typed_data';

import 'package:pxl/pxl.dart';

import 'src/prelude.dart';

void main() {
  group('IntPixels', () {
    test('creates a buffer', () {
      final pixels = IntPixels(3, 2);
      check(pixels).has((a) => a.width, 'width').equals(3);
      check(pixels).has((a) => a.height, 'height').equals(2);
      check(pixels).has((a) => a.format, 'format').equals(abgr8888);
      check(pixels).has((a) => a.length, 'length').equals(6);
      check(pixels).has((a) => a.data, 'data')
        ..isA<Uint32List>()
        ..deepEquals([0, 0, 0, 0, 0, 0]);
    });

    test('from a buffer', () {
      final src = IntPixels(
        2,
        2,
        data: Uint32List.fromList(
          [
            0xFFFFFFFF, 0x00000000, //
            0x00000000, 0xFFFFFFFF, //
          ],
        ),
      );
      final dst = IntPixels.from(src);
      check(dst.data[0]).equals(0xFFFFFFFF);
      check(dst.data[1]).equals(0x00000000);
      check(dst.data[2]).equals(0x00000000);
      check(dst.data[3]).equals(0xFFFFFFFF);
    });

    test('width cannot be less than 1', () {
      check(() => IntPixels(0, 1)).throws<ArgumentError>();
    });

    test('height cannot be less than 1', () {
      check(() => IntPixels(1, 0)).throws<ArgumentError>();
    });

    test('data length must match width * height', () {
      check(() => IntPixels(1, 1, data: Uint32List(2))).throws<RangeError>();
    });

    test('get out of bounds returns zero', () {
      final pixels = IntPixels(1, 1);
      check(pixels.get(Pos(1, 0))).equals(abgr8888.zero);
      check(pixels.get(Pos(0, 1))).equals(abgr8888.zero);
    });

    test('set out of bounds does nothing', () {
      final pixels = IntPixels(1, 1);
      pixels.set(Pos(1, 0), 0xFFFFFFFF);
      pixels.set(Pos(0, 1), 0xFFFFFFFF);
      check(pixels.data).every((a) => a.equals(abgr8888.zero));
    });

    test('get/set in bounds', () {
      final pixels = IntPixels(1, 1);
      pixels.set(Pos(0, 0), 0xFFFFFFFF);
      check(pixels.get(Pos(0, 0))).equals(0xFFFFFFFF);
    });
  });

  group('FloatPixels', () {
    test('creates a buffer', () {
      final pixels = FloatPixels(3, 2);
      check(pixels).has((a) => a.width, 'width').equals(3);
      check(pixels).has((a) => a.height, 'height').equals(2);
      check(pixels).has((a) => a.format, 'format').equals(floatRgba);
      check(pixels).has((a) => a.length, 'length').equals(6);
      check(pixels).has((a) => a.data, 'data')
        ..length.equals(6)
        ..every((a) => a.equals(Float32x4.zero()));
    });

    test('from a buffer', () {
      final src = FloatPixels(
        2,
        2,
        data: Float32x4List.fromList([
          floatRgba.red, floatRgba.green, //
          floatRgba.blue, floatRgba.cyan, //
        ]),
      );
      final dst = FloatPixels.from(src);
      check(dst.data[0]).equals(src.data[0]);
      check(dst.data[1]).equals(src.data[1]);
      check(dst.data[2]).equals(src.data[2]);
      check(dst.data[3]).equals(src.data[3]);
    });

    test('width cannot be less than 1', () {
      check(() => FloatPixels(0, 1)).throws<ArgumentError>();
    });

    test('height cannot be less than 1', () {
      check(() => FloatPixels(1, 0)).throws<ArgumentError>();
    });

    test('data length must match width * height', () {
      check(
        () => FloatPixels(1, 1, data: Float32x4List(2)),
      ).throws<RangeError>();
    });

    test('get out of bounds returns zero', () {
      final pixels = FloatPixels(1, 1);
      check(pixels.get(Pos(1, 0))).equals(Float32x4.zero());
      check(pixels.get(Pos(0, 1))).equals(Float32x4.zero());
    });

    test('set out of bounds does nothing', () {
      final pixels = FloatPixels(1, 1);
      pixels.set(Pos(1, 0), Float32x4(1.0, 1.0, 1.0, 1.0));
      pixels.set(Pos(0, 1), Float32x4(1.0, 1.0, 1.0, 1.0));
      check(pixels.data).every((a) => a.equals(Float32x4.zero()));
    });

    test('get/set in bounds', () {
      final pixels = FloatPixels(1, 1);
      pixels.set(Pos(0, 0), Float32x4(1.0, 1.0, 1.0, 1.0));
      check(pixels.get(Pos(0, 0))).equals(Float32x4(1.0, 1.0, 1.0, 1.0));
    });
  });

  test('fill', () {
    final pixels = IntPixels(2, 2);
    pixels.fill(0xFFFFFFFF);
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0xFFFFFFFF,
      0xFFFFFFFF,
      0xFFFFFFFF,
    ]);
  });

  test('fill (rect)', () {
    final pixels = IntPixels(2, 2);
    pixels.fill(0xFFFFFFFF, target: Rect.fromLTWH(1, 1, 1, 1));
    check(pixels.data).deepEquals([
      0x00000000,
      0x00000000,
      0x00000000,
      0xFFFFFFFF,
    ]);
  });

  test('fill (rect, partial, full width)', () {
    final pixels = IntPixels(2, 2);
    pixels.fill(0xFFFFFFFF, target: Rect.fromLTWH(0, 0, 2, 1));
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0xFFFFFFFF,
      0x00000000,
      0x00000000,
    ]);
  });

  test('fill (rect, partial)', () {
    final pixels = IntPixels(2, 2);
    pixels.fill(0xFFFFFFFF, target: Rect.fromLTWH(0, 0, 1, 1));
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0x00000000,
      0x00000000,
      0x00000000,
    ]);
  });

  test('fill (rect, clamped)', () {
    final pixels = IntPixels(2, 2);
    pixels.fill(0xFFFFFFFF, target: Rect.fromLTWH(1, 1, 2, 2));
    check(pixels.data).deepEquals([
      0x00000000,
      0x00000000,
      0x00000000,
      0xFFFFFFFF,
    ]);
  });

  test('clear', () {
    final pixels = IntPixels(
      2,
      2,
      data: Uint32List.fromList(
        [
          0xFFFFFFFF,
          0xFFFFFFFF,
          0xFFFFFFFF,
          0xFFFFFFFF,
        ],
      ),
    );
    pixels.clear();
    check(pixels.data).deepEquals([
      0x00000000,
      0x00000000,
      0x00000000,
      0x00000000,
    ]);
  });

  test('clear (rect)', () {
    final pixels = IntPixels(
      2,
      2,
      data: Uint32List.fromList(
        [
          0xFFFFFFFF,
          0xFFFFFFFF,
          0xFFFFFFFF,
          0xFFFFFFFF,
        ],
      ),
    );
    pixels.clear(target: Rect.fromLTWH(1, 1, 1, 1));
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0xFFFFFFFF,
      0xFFFFFFFF,
      0x00000000,
    ]);
  });

  test('fillWith', () {
    final pixels = IntPixels(2, 2);
    pixels.fillWith([0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF]);
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0xFFFFFFFF,
      0xFFFFFFFF,
      0xFFFFFFFF,
    ]);
  });

  test('fillWith (rect)', () {
    final pixels = IntPixels(2, 2);
    pixels.fillWith(
      [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF],
      target: Rect.fromLTWH(1, 1, 1, 1),
    );
    check(pixels.data).deepEquals([
      0x00000000,
      0x00000000,
      0x00000000,
      0xFFFFFFFF,
    ]);
  });

  test('fillWith (rect, partial)', () {
    final pixels = IntPixels(2, 2);
    pixels.fillWith(
      [0xFFFFFFFF, 0xFFFFFFFF],
      target: Rect.fromLTWH(0, 0, 1, 1),
    );
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0x00000000,
      0x00000000,
      0x00000000,
    ]);
  });

  test('fillWith (rect, clamped)', () {
    final pixels = IntPixels(2, 2);
    pixels.fillWith(
      [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF],
      target: Rect.fromLTWH(1, 1, 2, 2),
    );
    check(pixels.data).deepEquals([
      0x00000000,
      0x00000000,
      0x00000000,
      0xFFFFFFFF,
    ]);
  });

  test('fillWith (rect, insufficient data)', () {
    final pixels = IntPixels(2, 2);
    pixels.fillWith(
      [0xFFFFFFFF],
      target: Rect.fromLTWH(0, 0, 2, 2),
    );
    check(pixels.data).deepEquals([
      0xFFFFFFFF,
      0x00000000,
      0x00000000,
      0x00000000,
    ]);
  });

  test('fillWith (rect, too much data)', () {
    final pixels = IntPixels(2, 2);
    pixels.fillWith(
      [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF],
      target: Rect.fromLTWH(1, 1, 1, 1),
    );
    check(pixels.data).deepEquals([
      0x00000000,
      0x00000000,
      0x00000000,
      0xFFFFFFFF,
    ]);
  });

  test('getRange', () {
    final pixels = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    final range = pixels.getRange(Pos(1, 0), Pos(0, 1));
    check(range).deepEquals([abgr8888.green, abgr8888.blue]);
  });

  test('copyFrom (full, buffer -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    ).map((p) => p);
    final dst = IntPixels(2, 2);
    dst.copyFrom(src);

    check(dst.data).deepEquals([
      abgr8888.red,
      abgr8888.green,
      abgr8888.blue,
      abgr8888.cyan,
    ]);
  });

  test('copyFrom (full, pixels -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    final dst = IntPixels(2, 2);
    dst.copyFrom(src);

    check(dst.data).deepEquals([
      abgr8888.red,
      abgr8888.green,
      abgr8888.blue,
      abgr8888.cyan,
    ]);
  });

  test('copyFrom (partial, buffer -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    ).map((p) => p);
    final dst = IntPixels(2, 2);
    dst.copyFrom(src, target: Pos(1, 1));

    check(dst.data).deepEquals([
      abgr8888.zero,
      abgr8888.zero,
      abgr8888.zero,
      abgr8888.red,
    ]);
  });

  test('copyFrom (partial, pixels -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    final dst = IntPixels(2, 2);
    dst.copyFrom(src, target: Pos(1, 1));

    check(dst.data).deepEquals([
      abgr8888.zero,
      abgr8888.zero,
      abgr8888.zero,
      abgr8888.red,
    ]);
  });

  test('copyFrom (partial source, buffer -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    ).map((p) => p);
    final dst = IntPixels(2, 2);
    dst.copyFrom(src, source: Rect.fromLTWH(1, 1, 1, 1));

    check(dst.data).deepEquals([
      abgr8888.cyan,
      abgr8888.zero,
      abgr8888.zero,
      abgr8888.zero,
    ]);
  });

  test('blit (full, buffer -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.copyWithNormalized(abgr8888.red, alpha: 0.5),
        abgr8888.copyWithNormalized(abgr8888.green, alpha: 0.5),
        abgr8888.copyWithNormalized(abgr8888.blue, alpha: 0.5),
        abgr8888.copyWithNormalized(abgr8888.cyan, alpha: 0.5),
      ]),
    );
    final dst = IntPixels(2, 2);
    dst.blit(src.map((p) => p));

    check(dst.data).deepEquals([
      0xff00007f,
      0x00ff007f,
      0x0000ff7f,
      0x00ffff7f,
    ]);
  });

  test('blit (full, pixels -> pixels)', () {
    final src = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.copyWithNormalized(abgr8888.red, alpha: 0.5),
        abgr8888.copyWithNormalized(abgr8888.green, alpha: 0.5),
        abgr8888.copyWithNormalized(abgr8888.blue, alpha: 0.5),
        abgr8888.copyWithNormalized(abgr8888.cyan, alpha: 0.5),
      ]),
    );
    final dst = IntPixels(2, 2);
    dst.blit(src);

    check(dst.data).deepEquals([
      0xff00007f,
      0x00ff007f,
      0x0000ff7f,
      0x00ffff7f,
    ]);
  });
}
