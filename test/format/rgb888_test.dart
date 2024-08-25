import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('smoke test of RGB888 <> ABGR8888', () {
    check(rgb888.name).equals('RGB888');
    check(rgb888.bytesPerPixel).equals(4);

    check(rgb888.fromAbgr8888(abgr8888.black)).equalsHex(rgb888.black);
    check(rgb888.fromAbgr8888(abgr8888.red)).equalsHex(rgb888.red);
    check(rgb888.fromAbgr8888(abgr8888.green)).equalsHex(rgb888.green);
    check(rgb888.fromAbgr8888(abgr8888.blue)).equalsHex(rgb888.blue);
    check(rgb888.fromAbgr8888(abgr8888.yellow)).equalsHex(rgb888.yellow);
    check(rgb888.fromAbgr8888(abgr8888.cyan)).equalsHex(rgb888.cyan);
    check(rgb888.fromAbgr8888(abgr8888.magenta)).equalsHex(rgb888.magenta);
    check(rgb888.fromAbgr8888(abgr8888.white)).equalsHex(rgb888.white);

    check(rgb888.toAbgr8888(rgb888.black)).equalsHex(abgr8888.black);
    check(rgb888.toAbgr8888(rgb888.red)).equalsHex(abgr8888.red);
    check(rgb888.toAbgr8888(rgb888.green)).equalsHex(abgr8888.green);
    check(rgb888.toAbgr8888(rgb888.blue)).equalsHex(abgr8888.blue);
    check(rgb888.toAbgr8888(rgb888.yellow)).equalsHex(abgr8888.yellow);
    check(rgb888.toAbgr8888(rgb888.cyan)).equalsHex(abgr8888.cyan);
    check(rgb888.toAbgr8888(rgb888.magenta)).equalsHex(abgr8888.magenta);
    check(rgb888.toAbgr8888(rgb888.white)).equalsHex(abgr8888.white);
  });

  test('createNormalized', () {
    check(rgb888.createNormalized()).equalsHex(rgb888.black);
    check(
      rgb888.createNormalized(red: 1.0),
    ).equalsHex(rgb888.red);
    check(
      rgb888.createNormalized(green: 1.0),
    ).equalsHex(rgb888.green);
    check(
      rgb888.createNormalized(blue: 1.0),
    ).equalsHex(rgb888.blue);
    check(
      rgb888.createNormalized(red: 1.0, green: 1.0),
    ).equalsHex(rgb888.yellow);
    check(
      rgb888.createNormalized(green: 1.0, blue: 1.0),
    ).equalsHex(rgb888.cyan);
    check(
      rgb888.createNormalized(red: 1.0, blue: 1.0),
    ).equalsHex(rgb888.magenta);
    check(
      rgb888.createNormalized(red: 1.0, green: 1.0, blue: 1.0),
    ).equalsHex(rgb888.white);
  });

  test('fromFloatRgba', () {
    check(
      rgb888.fromFloatRgba(floatRgba.red),
    ).equalsHex(rgb888.red);
    check(
      rgb888.fromFloatRgba(floatRgba.green),
    ).equalsHex(rgb888.green);
    check(
      rgb888.fromFloatRgba(floatRgba.blue),
    ).equalsHex(rgb888.blue);
    check(
      rgb888.fromFloatRgba(floatRgba.yellow),
    ).equalsHex(rgb888.yellow);
    check(
      rgb888.fromFloatRgba(floatRgba.cyan),
    ).equalsHex(rgb888.cyan);
    check(
      rgb888.fromFloatRgba(floatRgba.magenta),
    ).equalsHex(rgb888.magenta);
    check(
      rgb888.fromFloatRgba(floatRgba.white),
    ).equalsHex(rgb888.white);
  });

  test('clamp', () {
    check(rgb888.clamp(-1)).equals(0xFFFFFF);
    check(rgb888.clamp(0)).equals(0);
    check(rgb888.clamp(0x7FFFFFFF)).equals(0xFFFFFF);
  });

  test('distance', () {
    check(rgb888.distance(rgb888.black, rgb888.black)).equals(0);
    check(rgb888.distance(rgb888.black, rgb888.white)).equals(195075.0);
    check(rgb888.distance(rgb888.red, rgb888.green)).equals(130050.0);
  });

  test('toFloatRgba', () {
    check(
      rgb888.toFloatRgba(rgb888.black),
    ).equals(floatRgba.black);
    check(
      rgb888.toFloatRgba(rgb888.red),
    ).equals(floatRgba.red);
    check(
      rgb888.toFloatRgba(rgb888.green),
    ).equals(floatRgba.green);
    check(
      rgb888.toFloatRgba(rgb888.blue),
    ).equals(floatRgba.blue);
    check(
      rgb888.toFloatRgba(rgb888.yellow),
    ).equals(floatRgba.yellow);
    check(
      rgb888.toFloatRgba(rgb888.cyan),
    ).equals(floatRgba.cyan);
    check(
      rgb888.toFloatRgba(rgb888.magenta),
    ).equals(floatRgba.magenta);
    check(
      rgb888.toFloatRgba(rgb888.white),
    ).equals(floatRgba.white);
  });
}
