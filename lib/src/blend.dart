import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pxl/src/format.dart';

part 'blend/porter_duff.dart';

/// Algorithms to use when painting on the canvas.
///
/// When drawing a shape or image onto a canvas, different algorithms can be
/// used to blend the pixels. A custom [BlendMode] can be used to implement
/// custom blending algorithms, or one of the predefined [BlendMode]s can be
/// used.
///
/// Each algorithm takes two colors as input, the _source_ color, which is the
/// color being drawn, and the _destination_ color, which is the color already
/// on the canvas. The algorithm then returns a new color that is the result of
/// blending the two colors.
///
/// {@category Blending}
@immutable
abstract interface class BlendMode {
  /// Destination pixels covered by the source are cleared to 0.
  static const BlendMode clear = PorterDuff(
    PorterDuff.zero,
    PorterDuff.zero,
  );

  /// Destination pixels are replaced by the source pixels.
  static const BlendMode src = PorterDuff(
    PorterDuff.one,
    PorterDuff.zero,
  );

  /// Source pixels are replaced by the destination pixels.
  static const BlendMode dst = PorterDuff(
    PorterDuff.zero,
    PorterDuff.one,
  );

  /// The source color is placed over the destination color.
  static const BlendMode srcOver = PorterDuff(
    PorterDuff.one,
    PorterDuff.oneMinusSrc,
  );

  /// The destination color is placed over the source color.
  static const BlendMode dstOver = PorterDuff(
    PorterDuff.oneMinusDst,
    PorterDuff.one,
  );

  /// The source that overlaps the destination replaces the destination.
  static const BlendMode srcIn = PorterDuff(
    PorterDuff.dst,
    PorterDuff.zero,
  );

  /// The destination that overlaps the source replaces the source.
  static const BlendMode dstIn = PorterDuff(
    PorterDuff.zero,
    PorterDuff.src,
  );

  /// The source that does not overlap the destination replaces the destination.
  static const BlendMode srcOut = PorterDuff(
    PorterDuff.oneMinusDst,
    PorterDuff.zero,
  );

  /// The destination that does not overlap the source replaces the source.
  static const BlendMode dstOut = PorterDuff(
    PorterDuff.zero,
    PorterDuff.oneMinusSrc,
  );

  /// The source that overlaps the destination is blended with the destination.
  static const BlendMode srcAtop = PorterDuff(
    PorterDuff.dst,
    PorterDuff.oneMinusSrc,
  );

  /// The destination that overlaps the source is blended with the source.
  static const BlendMode dstAtop = PorterDuff(
    PorterDuff.oneMinusDst,
    PorterDuff.src,
  );

  /// The non-overlapping regions of the source and destination are combined.
  static const BlendMode xor = PorterDuff(
    PorterDuff.oneMinusDst,
    PorterDuff.oneMinusSrc,
  );

  /// The source and destination regions are added together.
  static const BlendMode plus = PorterDuff(
    PorterDuff.one,
    PorterDuff.one,
  );

  /// Returns a function that blends two pixels together.
  T Function(S src, T dst) getBlend<S, T>(
    PixelFormat<S, void> srcFormat,
    PixelFormat<T, void> dstFormat,
  );
}
