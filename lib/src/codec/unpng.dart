/// Inspired from <https://www.da.vidbuchanan.co.uk/blog/hello-png.html>.
///
/// See also:
/// - <https://www.w3.org/TR/png-3/>
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:pxl/pxl.dart';

/// Encodes a buffer of integer pixel data as an uncompressed RGBA PNG image.
///
/// This encoder is intentionally minimal and does not support all features of
/// the PNG format. It's primary purpose is to provide a zero-dependency way to
/// visualize and persist pixel data in a standard format, i.e. for debugging
/// purposes, and it's recommended to use a dedicated library for more advanced
/// use cases.
///
/// ## Limitations
///
/// While the produced image is a valid PNG file, consider the following:
///
/// - The maximum resolution supported is 8192x8192.
/// - No compression is performed.
/// - Interlacing is not supported.
/// - Only RGBA color type is supported.
/// - Only 8-bit color depth is supported.
/// - No additional metadata or chunks are supported.
///
/// ## Alternatives
///
/// - In Flutter, prefer [`instantiateImageCodec`][1].
/// - In the browser, prefer [`HTMLCanvasElement toBlob`][2].
/// - In the standalone Dart VM, consider using [`package:image`][3].
///
/// [1]: https://api.flutter.dev/flutter/dart-ui/instantiateImageCodec.html
/// [2]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob
/// [3]: https://pub.dev/documentation/image/latest/image/PngEncoder-class.html
const uncompressedPngEncoder = UncompressedPngEncoder._();

/// Encodes a buffer of pixel data as an uncompressed RGBA PNG image with 8-bit
/// color depth.
///
/// A singleton instance of this class is available as [uncompressedPngEncoder].
final class UncompressedPngEncoder extends Converter<Pixels<int>, List<int>> {
  const UncompressedPngEncoder._();

  /// The maximum resolution we support is 8192x8192.
  static const _maxResolution = 0x2000;

  @override
  Uint8List convert(Buffer<int> input) {
    // Verify the resolution
    RangeError.checkValueInInterval(
      input.width,
      1,
      _maxResolution,
      'input.width',
    );
    RangeError.checkValueInInterval(
      input.height,
      1,
      _maxResolution,
      'input.height',
    );

    // Encode the PNG.
    return _encodeUncompressedPng(input);
  }
}

/// <https://www.w3.org/TR/png-3/#3PNGsignature>.
final _pngSignature = Uint8List(8)
  ..[0] = 0x89
  ..[1] = 0x50
  ..[2] = 0x4E
  ..[3] = 0x47
  ..[4] = 0x0D
  ..[5] = 0x0A
  ..[6] = 0x1A
  ..[7] = 0x0A;

Uint8List _encodeUncompressedPng<T>(Buffer<T> pixels) {
  final output = BytesBuilder(copy: false);

  // Write the PNG signature (https://www.w3.org/TR/png-3/#3PNGsignature).
  output.add(_pngSignature);

  // Writes a word to the output buffer in big-endian order.
  void writeWord(int value) {
    output.addByte(value >> 24 & 0xFF);
    output.addByte(value >> 16 & 0xFF);
    output.addByte(value >> 8 & 0xFF);
    output.addByte(value & 0xFF);
  }

  // Writes a chunk to the PNG buffer.
  void writeChunk(String type, Uint8List data) {
    // Write the length of the data.
    writeWord(data.length);

    // Store the current offset for the checksum.
    final offset = output.length;

    // Write the chunk type.
    output.add(utf8.encode(type));

    // Write the data.
    output.add(data);

    // Compute and write a CRC32 checksum excluding the length.
    final view = Uint8List.view(output.toBytes().buffer, offset);
    writeWord(_crc32(view));
  }

  // Write the IHDR chunk (https://www.w3.org/TR/png-3/#11IHDR).
  final ihdr = Uint8List(13)
    ..buffer.asByteData().setUint32(0, pixels.width) //  .3:  Width
    ..buffer.asByteData().setUint32(4, pixels.height) // .7:  Height
    ..[8] = 8 //                                         08:  Bit depth
    ..[9] = 6 //                                         09:  Color type (RGBA)
    ..[10] = 0 //                                        10:  Compression method
    ..[11] = 0 //                                        11:  Filter method
    ..[12] = 0; //                                       12:  Interlace method
  writeChunk('IHDR', ihdr);

  // Write the IDAT chunk (https://www.w3.org/TR/png-3/#11IDAT).
  final idat = BytesBuilder(copy: false)
    ..addByte(0x78) //  CMF (0x78 means 32K window size)
    ..addByte(0x01); // FLG (0x01 means no preset dictionary)

  // Hard-coded for 8-bit RGBA pixels.
  final baseStride = pixels.width * 4;
  final rowMagicLength = baseStride + 1;

  final rowMagicHeader = Uint8List(8)
    ..[0] = 0x02
    ..[1] = 0x08
    ..[2] = 0x00
    ..buffer.asByteData().setUint16(3, rowMagicLength, Endian.little)
    ..buffer.asByteData().setUint16(5, rowMagicLength ^ 0xFFFF, Endian.little)
    ..[7] = 0x00;

  var adlerSum = 1;
  for (var y = 0; y < pixels.height; y++) {
    // Write the row data.
    final row = Uint8List(baseStride);
    for (var x = 0; x < pixels.width; x++) {
      final offset = x * 4;
      final pixel = abgr8888.convert(
        pixels.getUnsafe(Pos(x, y)),
        from: pixels.format,
      );
      row[offset + 0] = abgr8888.getRed(pixel);
      row[offset + 1] = abgr8888.getGreen(pixel);
      row[offset + 2] = abgr8888.getBlue(pixel);
      row[offset + 3] = abgr8888.getAlpha(pixel);
    }

    // Update the Adler-32 checksum for the filter type and row data.
    adlerSum = _adler32(const [0], adlerSum);
    adlerSum = _adler32(row, adlerSum);

    // Write the header and row data.
    idat.add(rowMagicHeader);
    idat.add(row);
  }

  // Add the final deflate block of zero length, plus adler32 checksum.
  idat.addByte(0x02);
  idat.addByte(0x08);
  idat.addByte(0x30);
  idat.addByte(0x00);
  idat.addByte(adlerSum >> 24 & 0xFF);
  idat.addByte(adlerSum >> 16 & 0xFF);
  idat.addByte(adlerSum >> 8 & 0xFF);
  idat.addByte(adlerSum & 0xFF);
  writeChunk('IDAT', idat.toBytes());

  // Write the IEND chunk (https://www.w3.org/TR/png-3/#11IEND).
  writeChunk('IEND', Uint8List(0));

  return output.toBytes();
}

/// A table of lazily computed CRC-32 values for all 8-bit unsigned integers.
final _crc32Table = () {
  final table = Uint32List(256);
  for (var i = 0; i < 256; i++) {
    var c = i;
    for (var k = 0; k < 8; k++) {
      if ((c & 1) == 1) {
        c = 0xedb88320 ^ (c >> 1);
      } else {
        c = c >> 1;
      }
    }
    table[i] = c;
  }
  return table;
}();

/// Computes the CRC32 checksum of a list of bytes.
int _crc32(Uint8List bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc = _crc32Table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}

int _adler32(List<int> bytes, int seed) {
  var a = seed & 0xFFFF;
  var b = (seed >> 16) & 0xFFFF;
  for (final y in bytes) {
    a = (a + y) % 65521;
    b = (b + a) % 65521;
  }
  return (b << 16) | a;
}
