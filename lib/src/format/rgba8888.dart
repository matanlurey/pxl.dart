part of '../format.dart';

/// 32-bit RGBA pixel format with four 8-bit channels.
///
/// Colors in this format are represented as follows:
///
/// Color        | Value
/// -------------|------
/// [Rgba.red]   | `0xFF0000FF`
/// [Rgba.green] | `0x00FF00FF`
/// [Rgba.blue]  | `0x0000FFFF`
/// [Rgba.white] | `0xFFFFFFFF`
/// [Rgba.black] | `0x000000FF`
///
/// {@category Pixel Formats}
const rgba8888 = Argb8888._();

/// 32-bit RGBA pixel format with four 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [rgba8888].
///
/// {@category Pixel Formats}
final class Rgba8888 extends _Rgba8x4Int {
  const Rgba8888._() : super.fromRgbaOffsets(24, 16, 8, 0);

  @override
  String get name => 'RGBA8888';

  @override
  int fromAbgr8888(int pixel) => swapLane13(pixel);

  @override
  int toAbgr8888(int pixel) => swapLane13(pixel);
}
