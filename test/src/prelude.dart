import 'dart:typed_data';

import 'package:checks/context.dart';

export 'package:checks/checks.dart';
export 'package:test/test.dart' show TestOn, group, setUp, tearDown, test;

extension IntChecks on Subject<int> {
  void equalsHex(int expected) {
    context.expect(
      () => prefixFirst(
        'equals ',
        [
          '0x${expected.toRadixString(16)}',
        ],
      ),
      (actual) {
        if (actual == expected) return null;
        return Rejection(
          actual: ['0x${actual.toRadixString(16)}'],
          which: ['are not equal'],
        );
      },
    );
  }
}

extension Float32x4Checks on Subject<Float32x4> {
  void equals(Float32x4 other) {
    context.expect(() => prefixFirst('equals ', literal(other)), (actual) {
      final result = actual.equal(other);
      if (result.signMask != 0) return null;
      return Rejection(which: ['are not equal']);
    });
  }
}
