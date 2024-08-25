part of '../format.dart';

/// A simple 256-color system palette of common RGB colors.
///
/// The palette is generated automatically by combining 6 levels of red, green,
/// and blue channels to create 216 colors, followed by 40 shades of gray, for
/// a total of 256 unique colors.
///
/// {@category Pixel Formats}
final system256 = IndexedFormat.bits8(
  Iterable.generate(256, (i) {
    final r = ((i ~/ 36) % 6) * 51;
    final g = ((i ~/ 6) % 6) * 51;
    final b = (i % 6) * 51;

    // Ensure we generate 256 unique colors
    if (i >= 216) {
      final gray = (i - 216) * (255 / 40).floor();
      return abgr8888.create(red: gray, green: gray, blue: gray);
    } else {
      return abgr8888.create(red: r, green: g, blue: b);
    }
  }),
  format: abgr8888,
  name: 'SYSTEM_256',
);
