part of '../format.dart';

/// 32-bit ARGB pixel format with four 8-bit channels.
///
/// This is the most common pixel format for images with an alpha channel.
///
/// Colors in this format are represented as follows:
///
/// Color        | Value
/// -------------|------
/// [Rgba.red]   | `0xFF0000FF`
/// [Rgba.green] | `0xFF00FF00`
/// [Rgba.blue]  | `0xFFFF0000`
/// [Rgba.white] | `0xFFFFFFFF`
/// [Rgba.black] | `0xFF000000`
///
/// {@category Pixel Formats}
const argb8888 = Argb8888._();

/// 32-bit ARGB pixel format with four 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [argb8888].
///
/// {@category Pixel Formats}
final class Argb8888 extends _Rgba8x4Int {
  const Argb8888._() : super.fromRgbaOffsets(0, 8, 16, 24);

  @override
  String get name => 'ARGB8888';

  @override
  int fromAbgr8888(int pixel) => swapLane13(pixel);

  @override
  int toAbgr8888(int pixel) => swapLane13(pixel);
}
