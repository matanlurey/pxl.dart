import 'package:pxl/pxl.dart';

import 'src/prelude.dart';

void main() {
  group('system8', () {
    test('length is 8', () {
      check(system8).has((a) => a.length, 'length').equals(8);
    });

    test('bytesPerPixel is 1', () {
      check(system8).has((a) => a.bytesPerPixel, 'bytesPerPixel').equals(1);
    });

    test('[0] = black (#000000 in RGB)', () {
      check(system8[0]).equalsHex(0x000000);
    });

    test('[1] = red (#FF0000 in RGB)', () {
      check(system8[1]).equalsHex(0xFF0000);
    });

    test('[2] = green (#00FF00 in RGB)', () {
      check(system8[2]).equalsHex(0x00FF00);
    });

    test('[3] = blue (#0000FF in RGB)', () {
      check(system8[3]).equalsHex(0x0000FF);
    });

    test('[4] = yellow (#FFFF00 in RGB)', () {
      check(system8[4]).equalsHex(0xFFFF00);
    });

    test('[5] = cyan (#00FFFF in RGB)', () {
      check(system8[5]).equalsHex(0x00FFFF);
    });

    test('[6] = magenta (#FF00FF in RGB)', () {
      check(system8[6]).equalsHex(0xFF00FF);
    });

    test('[7] = white (#FFFFFF in RGB)', () {
      check(system8[7]).equalsHex(0xFFFFFF);
    });

    test('zero is 0', () {
      check(system8).has((a) => a.zero, 'zero').equals(0);
    });

    test('max is 7', () {
      check(system8).has((a) => a.max, 'max').equals(7);
    });

    test('clamp(0) is 0', () {
      check(system8.clamp(0)).equals(0);
    });

    test('clamp(7) is 7', () {
      check(system8.clamp(7)).equals(7);
    });

    test('clamp(-1) is 0', () {
      check(system8.clamp(-1)).equals(0);
    });

    test('clamp(8) is 7', () {
      check(system8.clamp(8)).equals(7);
    });

    test('fromAbgr8888(red) == red (1)', () {
      check(system8.fromAbgr8888(abgr8888.red)).equals(1);
    });

    test('convert(<orange red>) == red (1)', () {
      check(system8.convert(0xFF4500, from: rgb888)).equals(1);
    });
  });
}
