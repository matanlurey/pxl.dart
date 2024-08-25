import 'dart:typed_data';

import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('is named', () {
    check(floatRgba)
      ..has((a) => a.name, 'name').equals('FLOAT_RGBA')
      ..has((a) => a.toString(), 'toString()').equals('FLOAT_RGBA');
  });

  test('zero is transparent black', () {
    check(floatRgba.zero).equals(floatRgba.zero);
  });

  test('max is opaque white', () {
    check(floatRgba.max).equals(floatRgba.white);
  });

  group('copyWith', () {
    test('makes no changes if no parameters are passed', () {
      check(
        floatRgba.copyWith(floatRgba.red),
      ).equals(floatRgba.red);
    });

    test('changes alpha channel', () {
      check(
        floatRgba.copyWith(floatRgba.red, alpha: 0.5),
      ).equals(Float32x4(1.0, 0.0, 0.0, 0.5));
    });

    test('changes blue channel', () {
      check(
        floatRgba.copyWith(floatRgba.red, blue: 0.5),
      ).equals(Float32x4(1.0, 0.0, 0.5, 1.0));
    });

    test('changes green channel', () {
      check(
        floatRgba.copyWith(floatRgba.red, green: 0.5),
      ).equals(Float32x4(1.0, 0.5, 0.0, 1.0));
    });

    test('changes red channel', () {
      check(
        floatRgba.copyWith(floatRgba.red, red: 0.5),
      ).equals(Float32x4(0.5, 0.0, 0.0, 1.0));
    });
  });

  group('copyWithNormalized', () {
    test('makes no changes if no parameters are passed', () {
      check(
        floatRgba.copyWithNormalized(floatRgba.red),
      ).equals(floatRgba.red);
    });

    test('changes alpha channel', () {
      check(
        floatRgba.copyWithNormalized(floatRgba.red, alpha: 0.5),
      ).equals(Float32x4(1.0, 0.0, 0.0, 0.5));
    });

    test('changes blue channel', () {
      check(
        floatRgba.copyWithNormalized(floatRgba.red, blue: 0.5),
      ).equals(Float32x4(1.0, 0.0, 0.5, 1.0));
    });

    test('changes green channel', () {
      check(
        floatRgba.copyWithNormalized(floatRgba.red, green: 0.5),
      ).equals(Float32x4(1.0, 0.5, 0.0, 1.0));
    });

    test('changes red channel', () {
      check(
        floatRgba.copyWithNormalized(floatRgba.red, red: 0.5),
      ).equals(Float32x4(0.5, 0.0, 0.0, 1.0));
    });
  });

  group('fromAbgr8888', () {
    test('red -> red', () {
      check(
        floatRgba.fromAbgr8888(abgr8888.red),
      ).equals(floatRgba.red);
    });

    test('green -> green', () {
      check(
        floatRgba.fromAbgr8888(abgr8888.green),
      ).equals(floatRgba.green);
    });

    test('blue -> blue', () {
      check(
        floatRgba.fromAbgr8888(abgr8888.blue),
      ).equals(floatRgba.blue);
    });

    test('white -> white', () {
      check(
        floatRgba.fromAbgr8888(abgr8888.white),
      ).equals(floatRgba.white);
    });

    test('black -> black', () {
      check(
        floatRgba.fromAbgr8888(abgr8888.black),
      ).equals(floatRgba.black);
    });

    test('zero -> zero', () {
      check(
        floatRgba.fromAbgr8888(abgr8888.zero),
      ).equals(floatRgba.zero);
    });
  });

  group('toAbgr8888', () {
    test('red -> red', () {
      check(
        floatRgba.toAbgr8888(floatRgba.red),
      ).equals(abgr8888.red);
    });

    test('green -> green', () {
      check(
        floatRgba.toAbgr8888(floatRgba.green),
      ).equals(abgr8888.green);
    });

    test('blue -> blue', () {
      check(
        floatRgba.toAbgr8888(floatRgba.blue),
      ).equals(abgr8888.blue);
    });

    test('white -> white', () {
      check(
        floatRgba.toAbgr8888(floatRgba.white),
      ).equals(abgr8888.white);
    });

    test('black -> black', () {
      check(
        floatRgba.toAbgr8888(floatRgba.black),
      ).equals(abgr8888.black);
    });

    test('zero -> zero', () {
      check(
        floatRgba.toAbgr8888(floatRgba.zero),
      ).equals(abgr8888.zero);
    });
  });

  group('fromFloatRgba', () {
    test('red -> red', () {
      check(
        floatRgba.fromFloatRgba(floatRgba.red),
      ).equals(floatRgba.red);
    });

    test('green -> green', () {
      check(
        floatRgba.fromFloatRgba(floatRgba.green),
      ).equals(floatRgba.green);
    });

    test('blue -> blue', () {
      check(
        floatRgba.fromFloatRgba(floatRgba.blue),
      ).equals(floatRgba.blue);
    });

    test('white -> white', () {
      check(
        floatRgba.fromFloatRgba(floatRgba.white),
      ).equals(floatRgba.white);
    });

    test('black -> black', () {
      check(
        floatRgba.fromFloatRgba(floatRgba.black),
      ).equals(floatRgba.black);
    });

    test('zero -> zero', () {
      check(
        floatRgba.fromFloatRgba(floatRgba.zero),
      ).equals(floatRgba.zero);
    });
  });

  group('toFloatRgba', () {
    test('red -> red', () {
      check(
        floatRgba.toFloatRgba(floatRgba.red),
      ).equals(floatRgba.red);
    });

    test('green -> green', () {
      check(
        floatRgba.toFloatRgba(floatRgba.green),
      ).equals(floatRgba.green);
    });

    test('blue -> blue', () {
      check(
        floatRgba.toFloatRgba(floatRgba.blue),
      ).equals(floatRgba.blue);
    });

    test('white -> white', () {
      check(
        floatRgba.toFloatRgba(floatRgba.white),
      ).equals(floatRgba.white);
    });

    test('black -> black', () {
      check(
        floatRgba.toFloatRgba(floatRgba.black),
      ).equals(floatRgba.black);
    });

    test('zero -> zero', () {
      check(
        floatRgba.toFloatRgba(floatRgba.zero),
      ).equals(floatRgba.zero);
    });
  });

  group('clamp', () {
    test('< min', () {
      check(
        floatRgba.clamp(Float32x4(-1.0, -1.0, -1.0, -1.0)),
      ).equals(floatRgba.zero);
    });

    test('> max', () {
      check(
        floatRgba.clamp(Float32x4(2.0, 2.0, 2.0, 2.0)),
      ).equals(floatRgba.max);
    });
  });

  group('convert', () {
    test('identity', () {
      check(
        floatRgba.convert(floatRgba.red, from: floatRgba),
      ).equals(floatRgba.red);
    });

    test('abgr8888 -> floatRgba', () {
      check(
        floatRgba.convert(abgr8888.red, from: abgr8888),
      ).equals(floatRgba.red);
    });
  });

  test('bytesPerPixel', () {
    check(floatRgba).has((a) => a.bytesPerPixel, 'bytesPerPixel').equals(16);
  });

  test('distance', () {
    check(floatRgba.distance(floatRgba.red, floatRgba.green)).equals(2.0);
  });

  test('compare', () {
    check(floatRgba.compare(floatRgba.red, floatRgba.green)).equals(0.5);
  });

  test('minAlpha is 0', () {
    check(floatRgba).has((a) => a.minAlpha, 'minAlpha').equals(0.0);
  });
}
