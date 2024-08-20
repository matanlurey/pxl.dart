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

  group('Float32x4Pixels', () {
    test('creates a buffer', () {
      final pixels = Float32x4Pixels(3, 2);
      check(pixels).has((a) => a.width, 'width').equals(3);
      check(pixels).has((a) => a.height, 'height').equals(2);
      check(pixels).has((a) => a.format, 'format').equals(floatRgba);
      check(pixels).has((a) => a.length, 'length').equals(6);
      check(pixels).has((a) => a.data, 'data')
        ..length.equals(6)
        ..every((a) => a.equals(Float32x4.zero()));
    });

    test('width cannot be less than 1', () {
      check(() => Float32x4Pixels(0, 1)).throws<ArgumentError>();
    });

    test('height cannot be less than 1', () {
      check(() => Float32x4Pixels(1, 0)).throws<ArgumentError>();
    });

    test('data length must match width * height', () {
      check(
        () => Float32x4Pixels(1, 1, data: Float32x4List(2)),
      ).throws<RangeError>();
    });

    test('get out of bounds returns zero', () {
      final pixels = Float32x4Pixels(1, 1);
      check(pixels.getAt(Pos(1, 0))).equals(Float32x4.zero());
      check(pixels.getAt(Pos(0, 1))).equals(Float32x4.zero());
    });

    test('set out of bounds does nothing', () {
      final pixels = Float32x4Pixels(1, 1);
      pixels.setAt(Pos(1, 0), Float32x4(1.0, 1.0, 1.0, 1.0));
      pixels.setAt(Pos(0, 1), Float32x4(1.0, 1.0, 1.0, 1.0));
      check(pixels.data).every((a) => a.equals(Float32x4.zero()));
    });

    test('get/set in bounds', () {
      final pixels = Float32x4Pixels(1, 1);
      pixels.setAt(Pos(0, 0), Float32x4(1.0, 1.0, 1.0, 1.0));
      check(pixels.getAt(Pos(0, 0))).equals(Float32x4(1.0, 1.0, 1.0, 1.0));
    });
  });
}
