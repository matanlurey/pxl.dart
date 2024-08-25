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
