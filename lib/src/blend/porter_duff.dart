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
final class PorterDuff with BlendMode {
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
    return (src, dst) {
      final srcRgba = srcFormat.toFloatRgba(src);
      final dstRgba = dstFormat.toFloatRgba(dst);
      final result = _blendFloatRgba(srcRgba, dstRgba);
      return dstFormat.fromFloatRgba(result);
    };
  }

  Float32x4 _blendFloatRgba(Float32x4 src, Float32x4 dst) {
    return useSimd
        ? _blendFloat32x4SIMD(src, dst)
        : _blendFloat32x4Scalar(src, dst);
  }

  Float32x4 _blendFloat32x4Scalar(Float32x4 src, Float32x4 dst) {
    final Float32x4(
      x: sr,
      y: sg,
      z: sb,
      w: sa,
    ) = src;
    final Float32x4(
      x: dr,
      y: dg,
      z: db,
      w: da,
    ) = dst;

    final r = _src(sa, da) * sr + _dst(sa, da) * dr;
    final g = _src(sa, da) * sg + _dst(sa, da) * dg;
    final b = _src(sa, da) * sb + _dst(sa, da) * db;
    final a = _src(sa, da) * sa + _dst(sa, da) * da;
    return Float32x4(r, g, b, a);
  }

  Float32x4 _blendFloat32x4SIMD(Float32x4 src, Float32x4 dst) {
    final srcA = Float32x4.splat(_src(src.w, dst.w));
    final dstA = Float32x4.splat(_dst(src.w, dst.w));
    return src * srcA + dst * dstA;
  }
}
