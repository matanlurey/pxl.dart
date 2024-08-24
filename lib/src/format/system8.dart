part of '../format.dart';

/// A simple 8-color system palette of common RGB colors.
///
/// The palette contains the following colors in the order they are listed:
///
/// Index | Color
/// ------|------
/// 0     | Black
/// 1     | Red
/// 2     | Green
/// 3     | Blue
/// 4     | Yellow
/// 5     | Cyan
/// 6     | Magenta
/// 7     | White
///
/// {@category Pixel Formats}
final system8 = IndexedFormat.bits8(
  [
    abgr8888.black,
    abgr8888.red,
    abgr8888.green,
    abgr8888.blue,
    abgr8888.yellow,
    abgr8888.cyan,
    abgr8888.magenta,
    abgr8888.white,
  ],
  format: abgr8888,
  name: 'SYSTEM_8',
);

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
