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
final system8 = IndexedFormat.bits8(
  [
    rgb888.black,
    rgb888.red,
    rgb888.green,
    rgb888.blue,
    rgb888.yellow,
    rgb888.cyan,
    rgb888.magenta,
    rgb888.white,
  ],
  format: rgb888,
  name: 'SYSTEM_8',
);
