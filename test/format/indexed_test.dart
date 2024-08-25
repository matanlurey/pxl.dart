import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  group('system8', () {
    test('length is 8', () {
      check(system8).has((a) => a.length, 'length').equals(8);
    });

    test('bytesPerPixel is 1', () {
      check(system8).has((a) => a.bytesPerPixel, 'bytesPerPixel').equals(1);
    });

    test('[0] = black (#000000 in RGB)', () {
      check(system8[0]).equalsHex(abgr8888.black);
    });

    test('[1] = red (#FF0000 in RGB)', () {
      check(system8[1]).equalsHex(abgr8888.red);
    });

    test('[2] = green (#00FF00 in RGB)', () {
      check(system8[2]).equalsHex(abgr8888.green);
    });

    test('[3] = blue (#0000FF in RGB)', () {
      check(system8[3]).equalsHex(abgr8888.blue);
    });

    test('[4] = yellow (#FFFF00 in RGB)', () {
      check(system8[4]).equalsHex(abgr8888.yellow);
    });

    test('[5] = cyan (#00FFFF in RGB)', () {
      check(system8[5]).equalsHex(abgr8888.cyan);
    });

    test('[6] = magenta (#FF00FF in RGB)', () {
      check(system8[6]).equalsHex(abgr8888.magenta);
    });

    test('[7] = white (#FFFFFF in RGB)', () {
      check(system8[7]).equalsHex(abgr8888.white);
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
      check(system8.convert(0xFF0045FF, from: abgr8888)).equals(1);
    });

    test('copyWith is an identical copy', () {
      check(system8.copyWith(1)).equals(1);
    });

    test('copyWithNormal is an identical copy', () {
      check(system8.copyWithNormalized(1)).equals(1);
    });

    test('distance is a - b', () {
      check(system8.distance(1, 3)).equals(2);
    });

    test('compare compares the native values', () {
      check(system8.compare(1, 1)).equals(0);
      check(system8.compare(1, 3)).isCloseTo(0.00003, 0.00001);
    });

    test('fromFloatRbgba finds the closest color', () {
      check(system8.fromFloatRgba(floatRgba.black)).equals(0);
      check(system8.fromFloatRgba(floatRgba.red)).equals(1);
      check(system8.fromFloatRgba(floatRgba.green)).equals(2);
      check(system8.fromFloatRgba(floatRgba.blue)).equals(3);
      check(system8.fromFloatRgba(floatRgba.yellow)).equals(4);
      check(system8.fromFloatRgba(floatRgba.cyan)).equals(5);
      check(system8.fromFloatRgba(floatRgba.magenta)).equals(6);
      check(system8.fromFloatRgba(floatRgba.white)).equals(7);
    });

    test('out of range lookup returns zero', () {
      check(system8[-1]).equalsHex(abgr8888.zero);
      check(system8[8]).equalsHex(abgr8888.zero);
    });

    test('toAbgr8888 converts to the correct color', () {
      check(system8.toAbgr8888(0)).equalsHex(abgr8888.black);
      check(system8.toAbgr8888(1)).equalsHex(abgr8888.red);
      check(system8.toAbgr8888(2)).equalsHex(abgr8888.green);
      check(system8.toAbgr8888(3)).equalsHex(abgr8888.blue);
      check(system8.toAbgr8888(4)).equalsHex(abgr8888.yellow);
      check(system8.toAbgr8888(5)).equalsHex(abgr8888.cyan);
      check(system8.toAbgr8888(6)).equalsHex(abgr8888.magenta);
      check(system8.toAbgr8888(7)).equalsHex(abgr8888.white);
    });

    test('toFloatRgba converts to the correct color', () {
      check(system8.toFloatRgba(0)).equals(floatRgba.black);
      check(system8.toFloatRgba(1)).equals(floatRgba.red);
      check(system8.toFloatRgba(2)).equals(floatRgba.green);
      check(system8.toFloatRgba(3)).equals(floatRgba.blue);
      check(system8.toFloatRgba(4)).equals(floatRgba.yellow);
      check(system8.toFloatRgba(5)).equals(floatRgba.cyan);
      check(system8.toFloatRgba(6)).equals(floatRgba.magenta);
      check(system8.toFloatRgba(7)).equals(floatRgba.white);
    });
  });

  group('system256', () {
    test('the first 216 colors are RGB', () {
      for (var i = 0; i < 216; i++) {
        final r = ((i ~/ 36) % 6) * 51;
        final g = ((i ~/ 6) % 6) * 51;
        final b = (i % 6) * 51;
        check(system256[i]).equalsHex(
          abgr8888.create(red: r, green: g, blue: b),
        );
      }
    });

    test('the last 40 colors are grayscale', () {
      for (var i = 216; i < 256; i++) {
        final gray = (i - 216) * (255 / 40).floor();
        check(system256[i]).equalsHex(
          abgr8888.create(red: gray, green: gray, blue: gray),
        );
      }
    });
  });

  test('IndexedFormat.bits8 cannot exceed 256 elements', () {
    check(
      () => IndexedFormat.bits8(
        List.generate(257, (i) => i),
        format: abgr8888,
        name: 'test',
      ),
    ).throws<ArgumentError>();
  });

  test('IndexedFormat.bits8 name is INDEXED_{FORMAT}_{LENGTH}', () {
    final format = IndexedFormat.bits8(
      List.generate(8, (i) => i),
      format: abgr8888,
    );
    check(format.name).equals('INDEXED_ABGR8888_8');
  });

  test('IndexedFormat.bits16 cannot exceed 65536 elements', () {
    check(
      () => IndexedFormat.bits16(
        List.generate(65537, (i) => i),
        format: abgr8888,
        name: 'test',
      ),
    ).throws<ArgumentError>();
  });

  test('IndexedFormat.bits16 name is INDEXED_{FORMAT}_{LENGTH}', () {
    final format = IndexedFormat.bits16(
      List.generate(8, (i) => i),
      format: abgr8888,
    );
    check(format.name).equals('INDEXED_ABGR8888_8');
  });

  test('IndexedFormat.bits32 cannot exceed 4294967296 elements', () {
    check(
      () => IndexedFormat.bits32(
        // Allocating IRL this would likely OOM.
        _HugeList(),
        format: abgr8888,
        name: 'test',
      ),
    ).throws<ArgumentError>();
  });

  test('IndexedFormat.bits32 name is INDEXED_{FORMAT}_{LENGTH}', () {
    final format = IndexedFormat.bits32(
      List.generate(8, (i) => i),
      format: abgr8888,
    );
    check(format.name).equals('INDEXED_ABGR8888_8');
  });
}

final class _HugeList implements List<int> {
  @override
  int get length => 4294967297;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
