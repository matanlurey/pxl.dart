part of '../buffer.dart';

/// The result of a pixel comparison test.
///
/// {@category Output and Comparison}
final class ComparisonResult<T> {
  /// Compares two pixel buffers [a] and [b] and returns the result.
  factory ComparisonResult._compare(
    Buffer<T> a,
    Buffer<T> b, {
    double epsilon = 1e-10,
  }) {
    // If the dimension are different, the buffers are considered different.
    if (a.width != b.width || a.height != b.height) {
      return ComparisonResult._(1.0);
    }

    // Ensure the pixel formats are the same.
    b = b.mapConvert(a.format);

    // Calculate the difference between the two buffers.
    final aIterator = a.data.iterator;
    final bIterator = b.data.iterator;
    var pixelDiffCount = 0;
    while (aIterator.moveNext() && bIterator.moveNext()) {
      final diffPixel = a.format.compare(aIterator.current, bIterator.current);
      if (diffPixel > epsilon) {
        pixelDiffCount += 1;
      }
    }

    return ComparisonResult._(pixelDiffCount / a.length);
  }

  const ComparisonResult._(this.difference);

  /// The calculated percentage of pixel difference between two pixel buffers.
  final double difference;

  /// Whether the two pixel buffers were considered identical.
  ///
  /// Equivalent to `difference == 0.0`.
  bool get isIdentical => difference == 0.0;

  /// Whether the two pixel buffers were considered different.
  ///
  /// Equivalent to `difference != 0.0`.
  bool get isDifferent => difference != 0.0;

  @override
  String toString() => 'ComparisonResult <difference: $difference>';
}
