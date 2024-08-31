import 'dart:typed_data';

import 'package:pxl/pxl.dart';
import 'package:pxl/src/internal.dart';

import 'src/prelude.dart';

void main() {
  test('map', () {
    final buffer = IntPixels(
      1,
      3,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
      ]),
    );
    final converted = buffer.map((pixel) => pixel ^ 0xFFFFFFFF);
    check(converted.data.elementAt(0)).equalsHex(0x00ffff00);
    check(converted.data.elementAt(1)).equalsHex(0x00ff00ff);
    check(converted.data.elementAt(2)).equalsHex(0x0000ffff);
  });

  test('mapConvert', () {
    final buffer = IntPixels(
      2,
      3,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.yellow,
        abgr8888.cyan,
        abgr8888.magenta,
      ]),
    );
    final converted = buffer.mapConvert(floatRgba);
    check(converted.data.elementAt(0)).equals(floatRgba.red);
    check(converted.data.elementAt(1)).equals(floatRgba.green);
    check(converted.data.elementAt(2)).equals(floatRgba.blue);
    check(converted.data.elementAt(3)).equals(floatRgba.yellow);
    check(converted.data.elementAt(4)).equals(floatRgba.cyan);
    check(converted.data.elementAt(5)).equals(floatRgba.magenta);
  });

  test('mapIndexed', () {
    final buffer = IntPixels(
      1,
      3,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
      ]),
    );
    final converted = buffer.mapIndexed((pos, pixel) {
      if (pos.x == 0) {
        return abgr8888.magenta;
      }
      return pixel;
    });
    check(converted.data.elementAt(0)).equalsHex(abgr8888.magenta);
    check(converted.data.elementAt(1)).equalsHex(abgr8888.green);
    check(converted.data.elementAt(2)).equalsHex(abgr8888.blue);
  });

  test('mapClipped', () {
    final buffer = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    final clipped = buffer.mapRect(
      Rect.fromLTWH(0, 0, 1, 1),
    );
    check(clipped.length).equals(1);
    check(clipped.data).deepEquals([abgr8888.red]);
    check(clipped.get(Pos(0, 0))).equals(abgr8888.red);
  });

  test('mapClipped cannot be an empty rectangle', () {
    final buffer = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    check(
      () => buffer.mapRect(Rect.fromLTWH(1, 1, 0, 0)),
    ).throws<ArgumentError>();
  });

  test('mapClipped cannot intersect to an empty rectangle', () {
    final buffer = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    check(
      () => buffer.mapRect(Rect.fromLTWH(2, 2, 4, 4)),
    ).throws<ArgumentError>();
  });

  test('mapScaled', () {
    final buffer = IntPixels(
      2,
      2,
      data: Uint32List.fromList([
        abgr8888.red,
        abgr8888.green,
        abgr8888.blue,
        abgr8888.cyan,
      ]),
    );
    final scaled = buffer.mapScaled(2);
    check(scaled.width).equals(4);
    check(scaled.height).equals(4);
    check(scaled.data).deepEquals([
      abgr8888.red,
      abgr8888.red,
      abgr8888.green,
      abgr8888.green,
      abgr8888.red,
      abgr8888.red,
      abgr8888.green,
      abgr8888.green,
      abgr8888.blue,
      abgr8888.blue,
      abgr8888.cyan,
      abgr8888.cyan,
      abgr8888.blue,
      abgr8888.blue,
      abgr8888.cyan,
      abgr8888.cyan,
    ]);
  });

  group('compare', () {
    test('different width returns difference = 1.0', () {
      final a = IntPixels(2, 2);
      final b = IntPixels(3, 2);
      final diff = a.compare(b);
      check(diff.difference).equals(1.0);
    });

    test('different height returns difference = 1.0', () {
      final a = IntPixels(2, 2);
      final b = IntPixels(2, 3);
      final diff = a.compare(b);
      check(diff.difference).equals(1.0);

      if (isJsRuntime) {
        check(diff.toString()).contains('1');
      } else {
        check(diff.toString()).contains('1.0');
      }
    });

    test('different data returns difference = 1.0', () {
      final a = IntPixels(2, 2, data: Uint32List.fromList([0, 0, 0, 0]));
      final b = IntPixels(2, 2, data: Uint32List.fromList([1, 1, 1, 1]));
      final diff = a.compare(b);
      check(diff.difference).equals(1.0);
      check(diff.isIdentical).isFalse();
      check(diff.isDifferent).isTrue();
    });

    test('identical data returns difference = 0.0', () {
      final a = IntPixels(2, 2, data: Uint32List.fromList([0, 0, 0, 0]));
      final b = IntPixels(2, 2, data: Uint32List.fromList([0, 0, 0, 0]));
      final diff = a.compare(b);
      check(diff.difference).equals(0.0);
      check(diff.isIdentical).isTrue();
      check(diff.isDifferent).isFalse();
    });

    test('different data returns difference = 0.5', () {
      final a = IntPixels(2, 2, data: Uint32List.fromList([0, 0, 0, 0]));
      final b = IntPixels(2, 2, data: Uint32List.fromList([0, 1, 0, 1]));
      final diff = a.compare(b);
      check(diff.difference).equals(0.5);
    });
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
    final buffer = pixels.map((p) => p);
    final range = buffer.getRange(Pos(1, 0), Pos(0, 1));
    check(range).deepEquals([abgr8888.green, abgr8888.blue]);
  });

  test('getRange out of range returns nothing', () {
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
    final buffer = pixels.map((p) => p);
    final range = buffer.getRange(Pos(1, 2), Pos(2, 1));
    check(range).isEmpty();
  });

  test('getRect', () {
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
    final buffer = pixels.map((p) => p);
    final rect = buffer.getRect(Rect.fromLTWH(0, 0, 1, 1));
    check(rect).deepEquals([abgr8888.red]);
  });

  test('getRect, full width', () {
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
    final buffer = pixels.map((p) => p);
    final rect = buffer.getRect(Rect.fromLTWH(0, 0, 2, 1));
    check(rect).deepEquals([abgr8888.red, abgr8888.green]);
  });

  test('buffer.format is pixels.format', () {
    final buffer = IntPixels(2, 2).mapRect(Rect.fromLTWH(1, 1, 1, 1));
    check(buffer.format).equals(abgr8888);
  });

  test('buffer.getUnsafe maps to pixels.getUnsafe', () {
    final pixels = IntPixels(2, 2);
    pixels.data[0] = 0;
    pixels.data[1] = 1;
    pixels.data[2] = 2;
    pixels.data[3] = 3;
    final buffer = pixels.map((p) => p);
    check(buffer.getUnsafe(Pos(1, 1))).equals(pixels.getUnsafe(Pos(1, 1)));
  });
}
