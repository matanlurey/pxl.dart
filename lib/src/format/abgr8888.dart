part of '../format.dart';

/// 32-bit ABGR pixel format with four 8-bit channels.
///
/// This is the package's canonical integer-based pixel format.
///
/// Colors in this format are represented as follows:
///
/// Color        | Value
/// -------------|------
/// [Rgba.red]   | `0xFFFF0000`
/// [Rgba.green] | `0xFF00FF00`
/// [Rgba.blue]  | `0xFF0000FF`
/// [Rgba.white] | `0xFFFFFFFF`
/// [Rgba.black] | `0xFF000000`
///
/// {@category Pixel Formats}
const abgr8888 = Abgr8888._();

/// 32-bit ABGR pixel format with four 8-bit channels.
///
/// For a singleton instance of this class, and further details, see [abgr8888].
///
/// {@category Pixel Formats}
final class Abgr8888 extends _Rgba8x4Int {
  const Abgr8888._() : super.fromRgbaOffsets(16, 8, 0, 24);

  @override
  String get name => 'ABGR8888';

  @override
  int fromAbgr8888(int pixel) => pixel;

  @override
  int toAbgr8888(int pixel) => pixel;
}
