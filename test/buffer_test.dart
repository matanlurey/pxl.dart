import 'dart:typed_data';

import 'package:pxl/pxl.dart';

import 'prelude.dart';

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
}
