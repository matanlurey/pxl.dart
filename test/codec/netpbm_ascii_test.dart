import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('width must be at least 1', () {
    check(
      () => netpbmAsciiEncoder.convert(_ZeroWidthBuffer()),
    ).throws<ArgumentError>();
  });

  test('height must be at least 1', () {
    check(
      () => netpbmAsciiEncoder.convert(_ZeroHeightBuffer()),
    ).throws<ArgumentError>();
  });

  test('explicit bitmap', () {
    final pixels = IntPixels(3, 2);
    pixels.set(Pos(0, 0), abgr8888.white);
    pixels.set(Pos(1, 0), abgr8888.white);
    pixels.set(Pos(2, 0), abgr8888.white);

    final encoded = const NetpbmAsciiEncoder(
      format: NetpbmFormat.bitmap,
    ).convert(pixels);
    check(encoded).equals(
      [
        'P1',
        '3 2',
        '1 1 1',
        '0 0 0',
      ].join('\n'),
    );

    // Try decoding the encoded string.
    final decoded = netpbmAsciiDecoder.convert(encoded);
    check(decoded.format).equals(pixels.format);
    check(decoded.compare(pixels).difference).equals(0.0);
  });

  test('implicit bitmap', () {
    final monochrome = IndexedFormat.bits8(
      [
        abgr8888.black,
        abgr8888.white,
      ],
      format: abgr8888,
    );
    final pixels = IntPixels(3, 2, format: monochrome);
    pixels.set(Pos(0, 0), 1);
    pixels.set(Pos(1, 0), 1);
    pixels.set(Pos(2, 0), 1);

    final encoded = netpbmAsciiEncoder.convert(pixels);
    check(encoded).equals(
      [
        'P1',
        '3 2',
        '1 1 1',
        '0 0 0',
      ].join('\n'),
    );

    // Try decoding the encoded string.
    final decoded = NetpbmAsciiDecoder(format: monochrome).convert(encoded);
    check(decoded.compare(pixels).difference).equals(0.0);
  });

  test('implicit gray8', () {
    // Use multiple shades of gray to test the graymap format.
    final pixels = IntPixels(3, 1, format: gray8);
    pixels.set(Pos(0, 0), gray8.create(gray: 0));
    pixels.set(Pos(1, 0), gray8.create(gray: 128));
    pixels.set(Pos(2, 0), gray8.create(gray: 255));

    final encoded = const NetpbmAsciiEncoder(
      format: NetpbmFormat.graymap,
    ).convert(pixels);

    check(encoded).equals(
      [
        'P2',
        '3 1',
        '255',
        '  0 128 255',
      ].join('\n'),
    );

    // Try decoding the encoded string.
    final decoded = NetpbmAsciiDecoder(format: gray8).convert(encoded);
    check(decoded.format).equals(pixels.format);
    check(decoded.compare(pixels).difference).equals(0.0);
  });

  test('implicit pixmap', () {
    final pixels = IntPixels(3, 1);
    pixels.set(Pos(0, 0), abgr8888.red);
    pixels.set(Pos(1, 0), abgr8888.green);
    pixels.set(Pos(2, 0), abgr8888.blue);

    final encoded = const NetpbmAsciiEncoder(
      format: NetpbmFormat.pixmap,
    ).convert(pixels);

    check(encoded).equals(
      [
        'P3',
        '3 1',
        '255',
        '255   0   0   0 255   0   0   0 255',
      ].join('\n'),
    );

    // Try decoding the encoded string.
    final decoded = netpbmAsciiDecoder.convert(encoded);
    check(decoded.format).equals(pixels.format);
    check(decoded.compare(pixels).difference).equals(0.0);
  });
}

final class _ZeroWidthBuffer extends Buffer<int> {
  @override
  int get width => 0;

  @override
  int get height => 1;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ZeroHeightBuffer extends Buffer<int> {
  @override
  int get width => 1;

  @override
  int get height => 0;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
