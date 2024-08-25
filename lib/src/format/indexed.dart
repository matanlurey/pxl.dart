part of '../format.dart';

/// A pixel format that uses a predefined _palette_ to index colors.
///
/// Given a linear list of colors, an indexed pixel format uses a single integer
/// value to represent a color in the palette. This is useful for reducing the
/// memory footprint of images, especially when the number of unique colors is
/// small.
///
/// ## Example
///
/// ```dart
/// // Creating a simple system palette with 8 colors.
/// final palette = [
///   abgr8888.create(red: 0xFF, green: 0x00, blue: 0x00),
///   abgr8888.create(red: 0x00, green: 0xFF, blue: 0x00),
///   abgr8888.create(red: 0x00, green: 0x00, blue: 0xFF),
///   abgr8888.create(red: 0xFF, green: 0xFF, blue: 0x00),
///   abgr8888.create(red: 0xFF, green: 0x00, blue: 0xFF),
///   abgr8888.create(red: 0x00, green: 0xFF, blue: 0xFF),
///   abgr8888.create(red: 0xFF, green: 0xFF, blue: 0xFF),
///   abgr8888.create(red: 0x00, green: 0x00, blue: 0x00),
/// ];
///
/// // Creating an 8-bit indexed pixel format with the palette.
/// final indexed = IndexedFormat.bits8(palette, format: abgr8888);
///
/// // Converting a color to an index.
/// final index = indexed.fromAbgr8888(abgr8888.create(red: 0xFF, green: 0x00, blue: 0x00));
///
/// // Converting an index to a color.
/// final color = indexed.toAbgr8888(index);
/// ```
///
/// See [system8] for a predefined palette of common RGB colors.
///
/// {@category Pixel Formats}
final class IndexedFormat<P> extends PixelFormat<int, void> {
  /// Creates an 8-bit indexed pixel format with the given [palette].
  ///
  /// The [format] is used to convert between the palette colors and the
  /// indexed values.
  ///
  /// The [zero] and [max] values are used to clamp the indexed values to the
  /// valid range of the palette; if omitted, they default to `0` and
  /// `palette.length - 1` respectively.
  factory IndexedFormat.bits8(
    Iterable<P> palette, {
    required PixelFormat<P, void> format,
    String? name,
    int? zero,
    int? max,
  }) {
    if (palette.length > 256) {
      throw ArgumentError.value(
        palette.length,
        'palette.length',
        'Must be less than or equal to 256 for 8-bit indexed format.',
      );
    }
    return IndexedFormat._(
      List.of(palette),
      format,
      zero: zero ?? 0,
      max: max ?? palette.length - 1,
      bytesPerPixel: 1,
      name: name ?? 'INDEXED_${format.name}_${palette.length}',
    );
  }

  /// Creates an 16-bit indexed pixel format with the given [palette].
  ///
  /// The [format] is used to convert between the palette colors and the
  /// indexed values.
  ///
  /// The [zero] and [max] values are used to clamp the indexed values to the
  /// valid range of the palette; if omitted, they default to `0` and
  /// `palette.length - 1` respectively.
  factory IndexedFormat.bits16(
    Iterable<P> palette, {
    required PixelFormat<P, void> format,
    String? name,
    int? zero,
    int? max,
  }) {
    if (palette.length > 65536) {
      throw ArgumentError.value(
        palette.length,
        'palette.length',
        'Must be less than or equal to 65536 for 16-bit indexed format.',
      );
    }
    return IndexedFormat._(
      List.of(palette),
      format,
      zero: zero ?? 0,
      max: max ?? palette.length - 1,
      bytesPerPixel: 2,
      name: name ?? 'INDEXED_${format.name}_${palette.length}',
    );
  }

  /// Creates an 32-bit indexed pixel format with the given [palette].
  ///
  /// The [format] is used to convert between the palette colors and the
  /// indexed values.
  ///
  /// The [zero] and [max] values are used to clamp the indexed values to the
  /// valid range of the palette; if omitted, they default to `0` and
  /// `palette.length - 1` respectively.
  factory IndexedFormat.bits32(
    Iterable<P> palette, {
    required PixelFormat<P, void> format,
    String? name,
    int? zero,
    int? max,
  }) {
    // This, if each value is a 32-bit integer, is 16 GiB, and likely to OOM.
    if (palette.length > 4294967296) {
      throw ArgumentError.value(
        palette.length,
        'palette.length',
        'Must be less than or equal to 4294967296 for 32-bit indexed format.',
      );
    }
    return IndexedFormat._(
      List.of(palette),
      format,
      zero: zero ?? 0,
      max: max ?? palette.length - 1,
      bytesPerPixel: 4,
      name: name ?? 'INDEXED_${format.name}_${palette.length}',
    );
  }

  const IndexedFormat._(
    this._palette,
    this._format, {
    required this.zero,
    required this.max,
    required this.bytesPerPixel,
    required this.name,
  });

  final List<P> _palette;
  final PixelFormat<P, void> _format;

  @override
  final String name;

  @override
  final int bytesPerPixel;

  /// Length of the palette.
  int get length => _palette.length;

  /// The zero, or minimum, value for the pixel format.
  ///
  /// This value typically represents transparent and/or empty (black) pixels,
  /// but for an [IndexedFormat], it represents the index of the arbitrary color
  /// in the palette which **may not be transparent black**.
  @override
  final int zero;

  /// The maximum value for the pixel format.
  ///
  /// This value typically represents opaque and/or full (white) pixels, but for
  /// an [IndexedFormat], it represents the index of an arbitrary color in the
  /// palette which **may not be opaque white**.
  @override
  final int max;

  /// Clamps a [pixel] to the valid range of values for the pixel format.
  @override
  int clamp(int pixel) => pixel.clamp(0, length - 1);

  @override
  int copyWith(int pixel) => pixel;

  @override
  int copyWithNormalized(int pixel) => pixel;

  @override
  double distance(int a, int b) => (a - b).abs().toDouble();

  @override
  double compare(int a, int b) {
    return _format.compare(_palette[a], _palette[b]);
  }

  /// Converts a pixel in the [abgr8888] pixel format to `this` pixel format.
  ///
  /// The method returns the closest color in the palette to the given [pixel].
  @override
  int fromAbgr8888(int pixel) {
    return _findClosestIndex(_format.fromAbgr8888(pixel));
  }

  /// Converts a pixel in the [floatRgba] pixel format to `this` pixel format.
  ///
  /// The method returns the closest color in the palette to the given [pixel].
  @override
  int fromFloatRgba(Float32x4 pixel) {
    return _findClosestIndex(_format.fromFloatRgba(pixel));
  }

  /// Returns the color in the palette at the given [index].
  P operator [](int index) => _lookupByIndex(index);

  int _findClosestIndex(P color) {
    var closestIndex = 0;
    var closestDistance = double.infinity;
    for (var i = 0; i < length; i++) {
      final distance = _format.distance(_palette[i], color);
      if (distance < closestDistance) {
        closestIndex = i;
        closestDistance = distance;
      }
    }
    return closestIndex;
  }

  P _lookupByIndex(int index) {
    if (index < 0 || index >= length) {
      return _format.zero;
    }
    return _palette[index];
  }

  @override
  int toAbgr8888(int pixel) {
    return _format.toAbgr8888(_lookupByIndex(pixel));
  }

  @override
  Float32x4 toFloatRgba(int pixel) {
    return _format.toFloatRgba(_lookupByIndex(pixel));
  }
}
