import 'package:pxl/pxl.dart';

import 'src/prelude.dart';

void main() {
  test('is named', () {
    check(abgr8888)
      ..has((a) => a.name, 'name').equals('ABGR8888')
      ..has((a) => a.toString(), 'toString()').equals('ABGR8888');
  });

  test('zero is transparent black, 0x00000000', () {
    check(abgr8888).has((a) => a.zero, 'zero').equalsHex(0x00000000);
  });

  test('max is opaque white, 0xFFFFFFFF', () {
    check(abgr8888).has((a) => a.max, 'max').equalsHex(0xFFFFFFFF);
  });

  group('copyWith', () {
    test('makes no changes if no parameters are passed', () {
      check(abgr8888.copyWith(0x12345678)).equalsHex(0x12345678);
    });

    test('changes alpha channel', () {
      check(abgr8888.copyWith(0x12345678, alpha: 0x9A)).equalsHex(0x1234569A);
    });

    test('changes blue channel', () {
      check(abgr8888.copyWith(0x12345678, blue: 0x9A)).equalsHex(0x12349A78);
    });

    test('changes green channel', () {
      check(abgr8888.copyWith(0x12345678, green: 0x9A)).equalsHex(0x129A5678);
    });

    test('changes red channel', () {
      check(abgr8888.copyWith(0x12345678, red: 0x9A)).equalsHex(0x9A345678);
    });
  });

  group('copyWithNormalized', () {
    test('makes no changes if no parameters are passed', () {
      check(abgr8888.copyWithNormalized(0x12345678)).equalsHex(0x12345678);
    });

    test('changes alpha channel', () {
      check(
        abgr8888.copyWithNormalized(0x12345678, alpha: 0.5),
      ).equalsHex(0x1234567F);
    });

    test('changes blue channel', () {
      check(
        abgr8888.copyWithNormalized(0x12345678, blue: 0.5),
      ).equalsHex(0x12347F78);
    });

    test('changes green channel', () {
      check(
        abgr8888.copyWithNormalized(0x12345678, green: 0.5),
      ).equalsHex(0x127F5678);
    });

    test('changes red channel', () {
      check(
        abgr8888.copyWithNormalized(0x12345678, red: 0.5),
      ).equalsHex(0x7F345678);
    });
  });

  group('fromAbgr8888', () {
    test('red -> red', () {
      check(abgr8888.fromAbgr8888(abgr8888.red)).equalsHex(abgr8888.red);
    });

    test('green -> green', () {
      check(abgr8888.fromAbgr8888(abgr8888.green)).equalsHex(abgr8888.green);
    });

    test('blue -> blue', () {
      check(abgr8888.fromAbgr8888(abgr8888.blue)).equalsHex(abgr8888.blue);
    });

    test('white -> white', () {
      check(abgr8888.fromAbgr8888(abgr8888.white)).equalsHex(abgr8888.white);
    });

    test('black -> black', () {
      check(abgr8888.fromAbgr8888(abgr8888.black)).equalsHex(abgr8888.black);
    });

    test('zero -> zero', () {
      check(abgr8888.fromAbgr8888(abgr8888.zero)).equalsHex(abgr8888.zero);
    });
  });

  group('toAbgr8888', () {
    test('red -> red', () {
      check(abgr8888.toAbgr8888(abgr8888.red)).equalsHex(abgr8888.red);
    });

    test('green -> green', () {
      check(abgr8888.toAbgr8888(abgr8888.green)).equalsHex(abgr8888.green);
    });

    test('blue -> blue', () {
      check(abgr8888.toAbgr8888(abgr8888.blue)).equalsHex(abgr8888.blue);
    });

    test('white -> white', () {
      check(abgr8888.toAbgr8888(abgr8888.white)).equalsHex(abgr8888.white);
    });

    test('black -> black', () {
      check(abgr8888.toAbgr8888(abgr8888.black)).equalsHex(abgr8888.black);
    });

    test('zero -> zero', () {
      check(abgr8888.toAbgr8888(abgr8888.zero)).equalsHex(abgr8888.zero);
    });
  });

  group('fromFloatRgba', () {
    test('red -> red', () {
      check(
        abgr8888.fromFloatRgba(floatRgba.red),
      ).equalsHex(abgr8888.red);
    });

    test('green -> green', () {
      check(
        abgr8888.fromFloatRgba(floatRgba.green),
      ).equalsHex(abgr8888.green);
    });

    test('blue -> blue', () {
      check(
        abgr8888.fromFloatRgba(floatRgba.blue),
      ).equalsHex(abgr8888.blue);
    });

    test('white -> white', () {
      check(
        abgr8888.fromFloatRgba(floatRgba.white),
      ).equalsHex(abgr8888.white);
    });

    test('black -> black', () {
      check(
        abgr8888.fromFloatRgba(floatRgba.black),
      ).equalsHex(abgr8888.black);
    });

    test('zero -> zero', () {
      check(
        abgr8888.fromFloatRgba(floatRgba.zero),
      ).equalsHex(abgr8888.zero);
    });
  });

  group('toFloatRgba', () {
    test('red -> red', () {
      check(
        abgr8888.toFloatRgba(abgr8888.red),
      ).equals(floatRgba.red);
    });

    test('green -> green', () {
      check(
        abgr8888.toFloatRgba(abgr8888.green),
      ).equals(floatRgba.green);
    });

    test('blue -> blue', () {
      check(
        abgr8888.toFloatRgba(abgr8888.blue),
      ).equals(floatRgba.blue);
    });

    test('white -> white', () {
      check(
        abgr8888.toFloatRgba(abgr8888.white),
      ).equals(floatRgba.white);
    });

    test('black -> black', () {
      check(
        abgr8888.toFloatRgba(abgr8888.black),
      ).equals(floatRgba.black);
    });

    test('zero -> zero', () {
      check(
        abgr8888.toFloatRgba(abgr8888.zero),
      ).equals(floatRgba.zero);
    });
  });

  group('clamp', () {
    test('< min', () {
      check(abgr8888.clamp(-1)).equals(abgr8888.max);
    });

    test('> max', () {
      check(abgr8888.clamp(abgr8888.max + 1)).equals(abgr8888.zero);
    });
  });

  group('convert', () {
    test('identity', () {
      check(abgr8888.convert(0x12345678, from: abgr8888)).equalsHex(0x12345678);
    });

    test('floatRgba -> abgr8888', () {
      check(
        abgr8888.convert(floatRgba.red, from: floatRgba),
      ).equalsHex(abgr8888.red);
    });
  });
}
