@TestOn('vm')
library;

import 'dart:io' as io;
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:pxl/pxl.dart';
import 'src/prelude.dart';

final _updateGoldens = () {
  return switch (io.Platform.environment['UPDATE_GOLDENS']?.toUpperCase()) {
    'TRUE' || '1' => true,
    _ => false,
  };
}();

void main() {
  /// https://imagemagick.org/script/identify.php
  void identifyWithImageMagick(String path) {
    try {
      final result = io.Process.runSync('identify', [path]);
      check(result.exitCode, because: result.stderr.toString()).equals(0);
    } on io.ProcessException {
      io.stderr.writeln(
        'The `identify` command is not available. '
        'Please install ImageMagick to run this test.',
      );
    }
  }

  void checkOrUpdateGolden(String name, Uint8List bytes) {
    final path = p.join('test', 'golden', '$name.png');
    if (_updateGoldens) {
      io.File(path).writeAsBytesSync(bytes);
    } else {
      final golden = io.File(path).readAsBytesSync();
      check(
        bytes,
        because: ''
            'Golden file $path does not match the generated image.\n'
            'To update the golden file, set the environment variable '
            '`UPDATE_GOLDENS` to `true`. For example:\n'
            '  UPDATE_GOLDENS=true dart test',
      ).deepEquals(golden);
    }
    identifyWithImageMagick(path);
  }

  test('16x16 red pixel', () {
    final image = IntPixels(16, 16)..fill(abgr8888.red);
    checkOrUpdateGolden(
      '16x16_red_pixel',
      uncompressedPngEncoder.convert(image),
    );
  });

  test('16x16 blue pixel', () {
    final image = IntPixels(16, 16)..fill(abgr8888.blue);
    checkOrUpdateGolden(
      '16x16_blue_pixel',
      uncompressedPngEncoder.convert(image),
    );
  });

  test('16x16 green pixel', () {
    final image = IntPixels(16, 16)..fill(abgr8888.green);
    checkOrUpdateGolden(
      '16x16_green_pixel',
      uncompressedPngEncoder.convert(image),
    );
  });

  test('16x16 semi-transparent magenta pixel', () {
    final pixel = abgr8888.copyWithNormalized(abgr8888.magenta, alpha: 0.5);
    final image = IntPixels(16, 16)..fill(pixel);
    checkOrUpdateGolden(
      '16x16_semi-transparent_magenta',
      uncompressedPngEncoder.convert(image),
    );
  });
}
