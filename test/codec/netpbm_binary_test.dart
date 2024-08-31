import 'dart:convert';
import 'dart:typed_data';

import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('parses a header', () {
    final header = netpbmBinaryDecoder.parseHeader(
      utf8.encode('P4\n3 2\n'),
    );
    check(header).equals(
      NetpbmHeader(
        format: NetpbmFormat.bitmap,
        width: 3,
        height: 2,
      ),
    );
  });

  test('parses a header with a maximum value', () {
    final header = netpbmBinaryDecoder.parseHeader(
      utf8.encode('P5\n3 2\n255\n'),
    );
    check(header).equals(
      NetpbmHeader(
        format: NetpbmFormat.graymap,
        width: 3,
        height: 2,
        max: 255,
      ),
    );
  });

  test('parses a header with a comment', () {
    final header = netpbmBinaryDecoder.parseHeader(
      utf8.encode(
        'P6\n'
        '# comment\n'
        '3 2\n',
      ),
    );
    check(header).equals(
      NetpbmHeader(
        format: NetpbmFormat.pixmap,
        width: 3,
        height: 2,
        comments: ['comment'],
      ),
    );
  });

  test('width must be at least 1', () {
    check(
      () => netpbmBinaryEncoder.convert(_ZeroWidthBuffer()),
    ).throws<ArgumentError>();
  });

  test('height must be at least 1', () {
    check(
      () => netpbmBinaryEncoder.convert(_ZeroHeightBuffer()),
    ).throws<ArgumentError>();
  });

  test('explicit bitmap', () {
    final pixels = IntPixels(3, 2);
    pixels.set(Pos(0, 0), abgr8888.white);
    pixels.set(Pos(1, 0), abgr8888.white);
    pixels.set(Pos(2, 0), abgr8888.white);

    final encoded = const NetpbmBinaryEncoder(
      format: NetpbmFormat.bitmap,
    ).convert(pixels);
    check(encoded).deepEquals(
      Uint8List.fromList([
        ...utf8.encode('P4\n3 2\n'),
        1, 1, 1, //
        0, 0, 0, //
      ]),
    );

    // Try decoding the encoded string.
    final decoded = netpbmBinaryDecoder.convert(encoded);
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

    final encoded = netpbmBinaryEncoder.convert(pixels);
    check(encoded).deepEquals(
      Uint8List.fromList([
        ...utf8.encode('P4\n3 2\n'),
        1, 1, 1, //
        0, 0, 0, //
      ]),
    );

    // Try decoding the encoded string.
    final decoded = NetpbmBinaryDecoder(format: monochrome).convert(encoded);
    check(decoded.compare(pixels).difference).equals(0.0);
  });

  test('implicit gray8', () {
    // Use multiple shades of gray to test the graymap format.
    final pixels = IntPixels(3, 1, format: gray8);
    pixels.set(Pos(0, 0), gray8.create(gray: 0));
    pixels.set(Pos(1, 0), gray8.create(gray: 128));
    pixels.set(Pos(2, 0), gray8.create(gray: 255));

    final encoded = const NetpbmBinaryEncoder(
      format: NetpbmFormat.graymap,
    ).convert(pixels);

    check(encoded).deepEquals(
      Uint8List.fromList([
        ...utf8.encode('P5\n3 1\n255\n'),
        0, 128, 255, //
      ]),
    );

    // Try decoding the encoded string.
    final decoded = NetpbmBinaryDecoder(format: gray8).convert(encoded);
    check(decoded.format).equals(pixels.format);
    check(decoded.compare(pixels).difference).equals(0.0);
  });

  test('implicit pixmap', () {
    final pixels = IntPixels(3, 1);
    pixels.set(Pos(0, 0), abgr8888.red);
    pixels.set(Pos(1, 0), abgr8888.green);
    pixels.set(Pos(2, 0), abgr8888.blue);

    final encoded = const NetpbmBinaryEncoder(
      format: NetpbmFormat.pixmap,
    ).convert(pixels);

    check(encoded).deepEquals(
      Uint8List.fromList([
        ...utf8.encode('P6\n3 1\n255\n'),
        255, 0, 0, //
        0, 255, 0, //
        0, 0, 255, //
      ]),
    );

    // Try decoding the encoded string.
    final decoded = netpbmBinaryDecoder.convert(encoded);
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
