part of '../blend.dart';

/// A [BlendMode] that uses [Porter-Duff coefficients][1] to blend colors.
///
/// [1]: https://en.wikipedia.org/wiki/Alpha_compositing#Alpha_blending
///
/// A custom [BlendMode] can be created by providing custom coefficients to the
/// [PorterDuff] constructor:
///
/// ```dart
/// // Creates a custom blend mode that always returns zero.
/// final customBlendMode = PorterDuff(PorterDuff.zero, PorterDuff.one);
/// ```
///
/// {@category Blending}
final class PorterDuff implements BlendMode {
  /// Always returns zero (`0.0`).
  static double zero(double srcAlpha, double dstAlpha) => 0;

  /// Always returns one (`1.0`).
  static double one(double srcAlpha, double dstAlpha) => 1;

  /// Returns the source alpha channel (`srcAlpha`).
  static double src(double srcAlpha, double dstAlpha) => srcAlpha;

  /// Returns the destination alpha channel (`dstAlpha`).
  static double dst(double srcAlpha, double dstAlpha) => dstAlpha;

  /// Returns one minus the source alpha channel (`1 - srcAlpha`).
  static double oneMinusSrc(double srcAlpha, double dstAlpha) => 1 - srcAlpha;

  /// Returns one minus the destination alpha channel (`1 - dstAlpha`).
  static double oneMinusDst(double srcAlpha, double dstAlpha) => 1 - dstAlpha;

  /// Creates a blend mode with [Porter-Duff coefficients][1].
  ///
  /// [1]: https://en.wikipedia.org/wiki/Alpha_compositing#Alpha_blending
  ///
  /// The [src] and [dst] functions are used to calculate the source and
  /// destination coefficients, respectively. The result of blending the source
  /// and destination colors is calculated as:
  ///
  /// ```dart
  /// final srcAlpha = src(src.w, dst.w);
  /// final dstAlpha = dst(src.w, dst.w);
  /// return src * srcAlpha + dst * dstAlpha;
  /// ```
  const PorterDuff(this._src, this._dst);
  final double Function(double, double) _src;
  final double Function(double, double) _dst;

  @override
  T Function(S src, T dst) getBlend<S, T>(
    PixelFormat<S, void> srcFormat,
    PixelFormat<T, void> dstFormat,
  ) {
    if (identical(srcFormat, floatRgba) && identical(dstFormat, floatRgba)) {
      return _blendFloatRgba as T Function(S src, T dst);
    }
    return (src, dst) {
      final srcRgba = srcFormat.toFloatRgba(src);
      final dstRgba = dstFormat.toFloatRgba(dst);
      final result = _blendFloatRgba(srcRgba, dstRgba);
      return dstFormat.fromFloatRgba(result);
    };
  }

  Float32x4 _blendFloatRgba(Float32x4 src, Float32x4 dst) {
    final srcA = Float32x4.splat(_src(src.w, dst.w));
    final dstA = Float32x4.splat(_dst(src.w, dst.w));
    return src * srcA + dst * dstA;
  }
}
