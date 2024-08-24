import 'package:pxl/pxl.dart';

import 'src/prelude.dart';

void main() {
  test('BlendMode.clear', () {
    final src = abgr8888.red;
    final dst = abgr8888.green;
    final blend = BlendMode.clear.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(abgr8888.zero);
  });

  test('BlendMode.src', () {
    final src = abgr8888.red;
    final dst = abgr8888.green;
    final blend = BlendMode.src.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(src);
  });

  test('BlendMode.dst', () {
    final src = abgr8888.red;
    final dst = abgr8888.green;
    final blend = BlendMode.dst.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(dst);
  });

  test('BlendMode.srcOver', () {
    final src = abgr8888.create(red: 0x80, alpha: 0x80);
    final dst = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.srcOver.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0xbf803f00);
  });

  test('BlendMode.dstOver', () {
    final dst = abgr8888.create(red: 0x80, alpha: 0x80);
    final src = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.dstOver.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0xbf803f00);
  });

  test('BlendMode.srcIn', () {
    final src = abgr8888.create(red: 0x80, alpha: 0x80);
    final dst = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.srcIn.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x40400000);
  });

  test('BlendMode.dstIn', () {
    final dst = abgr8888.create(red: 0x80, alpha: 0x80);
    final src = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.dstIn.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x40400000);
  });

  test('BlendMode.srcOut', () {
    final src = abgr8888.create(red: 0x80, alpha: 0x80);
    final dst = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.srcOut.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x3f3f0000);
  });

  test('BlendMode.dstOut', () {
    final dst = abgr8888.create(red: 0x80, alpha: 0x80);
    final src = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.dstOut.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x3f3f0000);
  });

  test('BlendMode.srcAtop', () {
    final src = abgr8888.create(red: 0x80, alpha: 0x80);
    final dst = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.srcAtop.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x80403f00);
  });

  test('BlendMode.dstAtop', () {
    final dst = abgr8888.create(red: 0x80, alpha: 0x80);
    final src = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.dstAtop.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x80403f00);
  });

  test('BlendMode.xor', () {
    final src = abgr8888.create(red: 0x80, alpha: 0x80);
    final dst = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.xor.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0x7f3f3f00);
  });

  test('BlendMode.plus', () {
    final src = abgr8888.create(red: 0x80, alpha: 0x80);
    final dst = abgr8888.create(green: 0x80, alpha: 0x80);
    final blend = BlendMode.plus.getBlend(abgr8888, abgr8888);
    check(blend(src, dst)).equalsHex(0xff808000);
  });
}
