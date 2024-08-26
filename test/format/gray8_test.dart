import 'dart:typed_data';

import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('smoke test of GRAY8 <> ABGR8888', () {
    check(gray8.name).equals('GRAY8');
    check(gray8.bytesPerPixel).equals(1);
    check(gray8.maxGray).equals(255);
    check(gray8.max).equals(255);

    check(gray8.getGray(0x00)).equals(0);
    check(gray8.getGray(0x1d)).equals(29);
    check(gray8.getGray(0x96)).equals(150);

    check(gray8.fromAbgr8888(abgr8888.black)).equals(0);
    check(gray8.fromAbgr8888(abgr8888.blue)).equals(29);
    check(gray8.fromAbgr8888(abgr8888.green)).equals(150);
    check(gray8.fromAbgr8888(abgr8888.red)).equals(76);
    check(gray8.fromAbgr8888(abgr8888.white)).equals(255);

    check(gray8.fromFloatRgba(floatRgba.black)).equals(0);
    check(gray8.fromFloatRgba(floatRgba.blue)).equals(29);
    check(gray8.fromFloatRgba(floatRgba.green)).equals(150);
    check(gray8.fromFloatRgba(floatRgba.red)).equals(76);
    check(gray8.fromFloatRgba(floatRgba.white)).equals(255);

    check(gray8.toAbgr8888(0)).equalsHex(abgr8888.black);
    check(gray8.toAbgr8888(29)).equalsHex(0xff1d1d1d);
    check(gray8.toAbgr8888(150)).equalsHex(0xff969696);
    check(gray8.toAbgr8888(76)).equalsHex(0xff4c4c4c);
    check(gray8.toAbgr8888(255)).equalsHex(abgr8888.white);

    check(gray8.toFloatRgba(0)).equals(floatRgba.black);
    check(gray8.toFloatRgba(29)).equals(
      Float32x4(0.113725, 0.113725, 0.113725, 1.0),
    );
    check(gray8.toFloatRgba(150)).equals(
      Float32x4(0.588235, 0.588235, 0.588235, 1.0),
    );
    check(gray8.toFloatRgba(76)).equals(
      Float32x4(0.298039, 0.298039, 0.298039, 1.0),
    );
    check(gray8.toFloatRgba(255)).equals(floatRgba.white);
  });

  test('create', () {
    check(gray8.create(gray: 0)).equals(gray8.black);
    check(gray8.create(gray: 29)).equals(29);
    check(gray8.create(gray: 150)).equals(150);
    check(gray8.create(gray: 76)).equals(76);
    check(gray8.create(gray: 255)).equals(gray8.white);
  });

  test('distance', () {
    check(gray8.distance(0, 0)).equals(0);
    check(gray8.distance(0, 29)).equals(29);
  });

  test('compare', () {
    check(gray8.compare(0, 0)).equals(1.0);
    check(gray8.compare(0, 29)).equals(0.8862745098039215);
    check(gray8.compare(29, 0)).equals(0.8862745098039215);
    check(gray8.compare(29, 29)).equals(1.0);
  });

  test('minGray', () {
    check(gray8.minGray).equals(0);
  });

  test('clamp', () {
    check(gray8.clamp(-1)).equals(255);
    check(gray8.clamp(0)).equals(0);
    check(gray8.clamp(29)).equals(29);
    check(gray8.clamp(150)).equals(150);
    check(gray8.clamp(76)).equals(76);
    check(gray8.clamp(255)).equals(255);
    check(gray8.clamp(256)).equals(0);
  });
}
