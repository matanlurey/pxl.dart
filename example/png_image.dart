#!/usr/bin/env dart

import 'dart:io';

import 'package:pxl/pxl.dart';
import 'package:pxl/src/codec/unpng.dart';

void main() {
  final image = IntPixels(1, 1, format: argb8888);
  image.fill(argb8888.red);

  final bytes = uncompressedPngEncoder.convert(image);
  File('example.png').writeAsBytesSync(bytes);
}
