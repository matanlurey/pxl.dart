@TestOn('vm')
library;

import 'dart:io' as io;
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:pxl/pxl.dart';

import 'src/embed.dart';
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

  test('embeded font', () {
    final image = terminal8x8Font;
    checkOrUpdateGolden(
      'terminal8x8_font',
      uncompressedPngEncoder.convert(image),
    );
  });

  test('copyFrom with embedded font', () {
    // We are going to write the word "PXL" in the terminal8x8Font.
    // The font is stored in code page 437 tile order.
    final $P = Pos(00, 5) * 8;
    final $X = Pos(08, 5) * 8;
    final $L = Pos(12, 4) * 8;

    final output = IntPixels(24, 8);
    output.copyFrom(
      terminal8x8Font,
      source: Rect.fromWH(8, 8, offset: $P),
      target: Pos(00, 00),
    );

    output.copyFrom(
      terminal8x8Font,
      source: Rect.fromWH(8, 8, offset: $X),
      target: Pos(08, 00),
    );

    output.copyFrom(
      terminal8x8Font,
      source: Rect.fromWH(8, 8, offset: $L),
      target: Pos(16, 00),
    );

    checkOrUpdateGolden(
      'copyFrom_with_embedded_font',
      uncompressedPngEncoder.convert(output),
    );
  });

  test('blit with embedded font', () {
    // We are going to write the word "PXL" in the terminal8x8Font.
    // The font is stored in code page 437 tile order.
    final $P = Pos(00, 5) * 8;
    final $X = Pos(08, 5) * 8;
    final $L = Pos(12, 4) * 8;

    final output = IntPixels(24, 8)..fill(abgr8888.magenta);
    final input = IntPixels.from(
      terminal8x8Font.map((i) {
        // Make every white pixel semi-transparent blue;
        return i == 0 ? i : abgr8888.create(blue: 0xFF, alpha: 0x80);
      }),
    );

    output.blit(
      input,
      target: Pos(00, 00),
      source: Rect.fromWH(8, 8, offset: $P),
    );

    output.blit(
      input,
      target: Pos(08, 00),
      source: Rect.fromWH(8, 8, offset: $X),
    );

    output.blit(
      input,
      target: Pos(16, 00),
      source: Rect.fromWH(8, 8, offset: $L),
    );

    checkOrUpdateGolden(
      'blit_with_embedded_font',
      uncompressedPngEncoder.convert(output),
    );
  });

  test('blit with embedded font and scaling', () {
    // We are going to write the word "PXL" in the terminal8x8Font.
    // The font is stored in code page 437 tile order.
    final $P = Pos(00, 5) * 8;
    final $X = Pos(08, 5) * 8;
    final $L = Pos(12, 4) * 8;

    final output = IntPixels(24 * 4, 8 * 4)..fill(abgr8888.black);
    final scaled = terminal8x8Font.mapScaled(4);

    output.blit(
      scaled,
      target: Pos(00, 00),
      source: Rect.fromWH(8 * 4, 8 * 4, offset: $P * 4),
    );

    output.blit(
      scaled,
      target: Pos(08 * 4, 00),
      source: Rect.fromWH(8 * 4, 8 * 4, offset: $X * 4),
    );

    output.blit(
      scaled,
      target: Pos(16 * 4, 00),
      source: Rect.fromWH(8 * 4, 8 * 4, offset: $L * 4),
    );

    checkOrUpdateGolden(
      'blit_with_embedded_font_and_scaling',
      uncompressedPngEncoder.convert(output),
    );
  });
}
