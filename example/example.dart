#!/usr/bin/env dart

import 'dart:io';
import 'dart:math' as math;

import 'package:pxl/pxl.dart';

void main() {
  const imageWidth = 680;
  const imageHeight = 256;
  final image = IntPixels(imageWidth, imageHeight);

  // Fill background with green
  image.fill(abgr8888.green);

  // Draw a gradient sky
  for (var y = 0; y < imageHeight / 2; y++) {
    final blue = (y / (imageHeight / 2) * 255).toInt();
    image.fill(
      abgr8888.create(blue: blue),
      Rect.fromLTWH(0, y, imageWidth, 1),
    );
  }

  // Draw a pixelated yellow sun
  final sunCenter = Pos.floor(imageWidth / 2, imageHeight / 4);
  const sunRadius = 128;
  for (var y = sunCenter.y - sunRadius; y <= sunCenter.y + sunRadius; y++) {
    for (var x = sunCenter.x - sunRadius; x <= sunCenter.x + sunRadius; x++) {
      final distance = sunCenter.distanceTo(Pos(x, y));
      if (distance <= sunRadius) {
        final intensity = 255 - (distance / sunRadius * 255).toInt();
        image.set(
          Pos(x, y),
          abgr8888.create(red: 255 - intensity, green: 255 - intensity),
        );
      }
    }
  }

  // Draw some pixelated clouds
  final rng = math.Random();
  for (var i = 0; i < 64; i++) {
    final cloudX = rng.nextInt(imageWidth - 10);
    final cloudY = rng.nextInt(imageHeight ~/ 2 - 5);
    final cloudWidth = rng.nextInt(10) + 5;
    final cloudHeight = rng.nextInt(5) + 3;

    for (var y = cloudY; y < cloudY + cloudHeight; y++) {
      for (var x = cloudX; x < cloudX + cloudWidth; x++) {
        if (rng.nextDouble() < 0.7) {
          // Some randomness for cloud shape
          image.set(Pos(x, y), abgr8888.white);
        }
      }
    }
  }

  // Save the image
  final bytes = uncompressedPngEncoder.convert(image);
  File('example.png').writeAsBytesSync(bytes);
}
