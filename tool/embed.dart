#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io' as io;

import 'package:image/image.dart';
import 'package:path/path.dart' as p;
import 'package:pxl/pxl.dart';

void main() {
  final file = io.File(p.join('tool', 'terminal8x8.png'));
  final bytes = file.readAsBytesSync();
  final image = decodePng(bytes)!;

  // Create a buffer to write the image to.
  final buffer = IntPixels(image.width, image.height);

  // Write the image to the buffer.
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final color = image.getPixel(x, y);
      if (color.r < 20 && color.g < 20 && color.b < 20) {
        buffer.set(Pos(x, y), abgr8888.zero);
      } else {
        buffer.set(Pos(x, y), abgr8888.white);
      }
    }
  }

  final output = packedBitmapEncoder.convert(buffer);
  final base64 = base64Encode(output.buffer.asUint8List());
  io.stdout.write(base64);
}
