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
      check(pixels.getAt(Pos(1, 0))).equals(abgr8888.zero);
      check(pixels.getAt(Pos(0, 1))).equals(abgr8888.zero);
    });

    test('set out of bounds does nothing', () {
      final pixels = IntPixels(1, 1);
      pixels.setAt(Pos(1, 0), 0xFFFFFFFF);
      pixels.setAt(Pos(0, 1), 0xFFFFFFFF);
      check(pixels.data).every((a) => a.equals(abgr8888.zero));
    });

    test('get/set in bounds', () {
      final pixels = IntPixels(1, 1);
      pixels.setAt(Pos(0, 0), 0xFFFFFFFF);
      check(pixels.getAt(Pos(0, 0))).equals(0xFFFFFFFF);
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
      check(pixels.getAt(Pos(1, 0))).equals(Float32x4.zero());
      check(pixels.getAt(Pos(0, 1))).equals(Float32x4.zero());
    });

    test('set out of bounds does nothing', () {
      final pixels = FloatPixels(1, 1);
      pixels.setAt(Pos(1, 0), Float32x4(1.0, 1.0, 1.0, 1.0));
      pixels.setAt(Pos(0, 1), Float32x4(1.0, 1.0, 1.0, 1.0));
      check(pixels.data).every((a) => a.equals(Float32x4.zero()));
    });

    test('get/set in bounds', () {
      final pixels = FloatPixels(1, 1);
      pixels.setAt(Pos(0, 0), Float32x4(1.0, 1.0, 1.0, 1.0));
      check(pixels.getAt(Pos(0, 0))).equals(Float32x4(1.0, 1.0, 1.0, 1.0));
    });
  });

  group('blit', () {
    test('copy in same format', () {
      final src = IntPixels(
        2,
        2,
        data: Uint32List.fromList([
          abgr8888.red, abgr8888.green, //
          abgr8888.blue, abgr8888.cyan, //
        ]),
      );

      final dst = IntPixels(2, 2);
      Pixels.blit(src, dst);

      check(dst.data).deepEquals(src.data);
    });

    test('copy in different format', () {
      final src = FloatPixels(
        2,
        2,
        data: Float32x4List.fromList([
          floatRgba.red, floatRgba.green, //
          floatRgba.blue, floatRgba.cyan, //
        ]),
      );

      final dst = IntPixels(2, 2);
      Pixels.blit(src, dst);

      check(dst.data).deepEquals([
        abgr8888.red, abgr8888.green, //
        abgr8888.blue, abgr8888.cyan, //
      ]);
    });

    test('copy with blend', () {
      final src = IntPixels(
        2,
        2,
        data: Uint32List.fromList([
          abgr8888.red, abgr8888.green, //
          abgr8888.blue, abgr8888.cyan, //
        ]),
      );

      final dst = IntPixels(2, 2, data: Uint32List.fromList([0, 0, 0, 0]));
      Pixels.blit(src, dst, blend: (s, d) => s + 1);

      check(dst.data).deepEquals([
        abgr8888.red + 1, abgr8888.green + 1, //
        abgr8888.blue + 1, abgr8888.cyan + 1, //
      ]);
    });

    test('copy to a smaller destination', () {
      final src = IntPixels(
        2,
        2,
        data: Uint32List.fromList([
          abgr8888.red, abgr8888.green, //
          abgr8888.blue, abgr8888.cyan, //
        ]),
      );

      final dst = IntPixels(1, 1);
      Pixels.blit(src, dst);

      check(dst.data).deepEquals([abgr8888.red]);
    });

    test('copy to a larger destination', () {
      final src = IntPixels(
        1,
        1,
        data: Uint32List.fromList([abgr8888.red]),
      );

      final dst = IntPixels(2, 2);
      Pixels.blit(src, dst);

      check(dst.data).deepEquals([
        abgr8888.red, abgr8888.zero, //
        abgr8888.zero, abgr8888.zero, //
      ]);
    });

    test('copy to an offset destination', () {
      final src = IntPixels(
        1,
        1,
        data: Uint32List.fromList([abgr8888.red]),
      );

      final dst = IntPixels(2, 2, data: Uint32List.fromList([0, 0, 0, 0]));
      Pixels.blit(src, dst, destination: Pos(1, 1));

      check(dst.data).deepEquals([
        abgr8888.zero, abgr8888.zero, //
        abgr8888.zero, abgr8888.red, //
      ]);
    });
  });
}
