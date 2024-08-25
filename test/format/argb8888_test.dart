import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('smoke test of ARGB8888 <> ABGR8888', () {
    check(argb8888.name).equals('ARGB8888');

    check(argb8888.fromAbgr8888(abgr8888.black)).equalsHex(argb8888.black);
    check(argb8888.fromAbgr8888(abgr8888.red)).equalsHex(argb8888.red);
    check(argb8888.fromAbgr8888(abgr8888.green)).equalsHex(argb8888.green);
    check(argb8888.fromAbgr8888(abgr8888.blue)).equalsHex(argb8888.blue);
    check(argb8888.fromAbgr8888(abgr8888.yellow)).equalsHex(argb8888.yellow);
    check(argb8888.fromAbgr8888(abgr8888.cyan)).equalsHex(argb8888.cyan);
    check(argb8888.fromAbgr8888(abgr8888.magenta)).equalsHex(argb8888.magenta);
    check(argb8888.fromAbgr8888(abgr8888.white)).equalsHex(argb8888.white);

    check(argb8888.toAbgr8888(argb8888.black)).equalsHex(abgr8888.black);
    check(argb8888.toAbgr8888(argb8888.red)).equalsHex(abgr8888.red);
    check(argb8888.toAbgr8888(argb8888.green)).equalsHex(abgr8888.green);
    check(argb8888.toAbgr8888(argb8888.blue)).equalsHex(abgr8888.blue);
    check(argb8888.toAbgr8888(argb8888.yellow)).equalsHex(abgr8888.yellow);
    check(argb8888.toAbgr8888(argb8888.cyan)).equalsHex(abgr8888.cyan);
    check(argb8888.toAbgr8888(argb8888.magenta)).equalsHex(abgr8888.magenta);
    check(argb8888.toAbgr8888(argb8888.white)).equalsHex(abgr8888.white);
  });
}
