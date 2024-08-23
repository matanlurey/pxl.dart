import 'dart:typed_data';

import 'package:pxl/pxl.dart';

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
    check(converted.data.elementAt(0)).equalsHex(0x00FFFF00);
    check(converted.data.elementAt(1)).equalsHex(0xFF00FF00);
    check(converted.data.elementAt(2)).equalsHex(0xFFFF0000);
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
    final clipped = buffer.mapClipped(
      Rect.fromLTWH(0, 0, 1, 1),
    );
    check(clipped.length).equals(1);
    check(clipped.data).deepEquals([abgr8888.red]);
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
}
