import 'dart:convert';
import 'dart:typed_data';

import 'package:pxl/pxl.dart';

/// Codec for encoding and decoding packed bitmaps.
///
/// A packed bitmap is a compact binary representation of a bitmap, where each
/// pixel is encoded as a single bit. This can be useful for storing large
/// bitmaps in a compact format, at the cost of some overhead to pack and
/// unpack the data.
const packedBitmapCodec = PackedBitmapCodec._();

/// Codec for encoding and decoding packed bitmaps.
final class PackedBitmapCodec extends Codec<Buffer<int>, List<int>> {
  const PackedBitmapCodec._();

  @override
  Converter<Buffer<int>, Uint32List> get encoder => packedBitmapEncoder;

  @override
  Converter<List<int>, Buffer<int>> get decoder => packedBitmapDecoder;

  @override
  Buffer<int> decode(
    List<int> encoded, {
    PixelFormat<int, void> format = abgr8888,
  }) {
    return packedBitmapDecoder.convert(encoded, format: format);
  }
}

/// Encodes a bitmap to a compact (packed) binary format.
///
/// See [PackedBitmapEncoder] for details.
const packedBitmapEncoder = PackedBitmapEncoder._();

/// Encodes a bitmap to a compact (packed) binary format.
///
/// For a given buffer, [PixelFormat.zero] is encoded as `0`, and any other
/// value is encoded as `1`. 32 values are packed into a single byte, with the
/// least significant bit representing the first value. The first two 32-bit
/// words of the output are the width and height of the bitmap, respectively.
///
/// For example, a 128x128 bitmap, which normally would require 2048 bytes,
/// can be encoded into 256 bytes (128 * 128 / 32), or a 8x reduction in size,
/// at the cost of some overhead to pack and unpack the data.
///
/// A singleton instance of this class is available as [packedBitmapEncoder].
final class PackedBitmapEncoder extends Converter<Buffer<int>, Uint32List> {
  const PackedBitmapEncoder._();

  @override
  Uint32List convert(Buffer<int> input) {
    final width = input.width;
    final height = input.height;
    final data = input.data;

    // Convert every 32 pixels into 32-bits.
    // That is, a 128x128 bitmap is represented as 4x4 32-bit words.
    final output = Uint32List(2 + (data.length ~/ 32));
    output[0] = width;
    output[1] = height;

    var word = 0;
    var bit = 0;
    var offset = 2;
    for (final pixel in input.data) {
      if (pixel != input.format.zero) {
        word |= 1 << bit;
      }
      bit++;
      if (bit == 32) {
        output[offset] = word;
        word = 0;
        bit = 0;
        offset++;
      }
    }

    return output;
  }
}

/// Decodes a bitmap from a compact (packed) binary format.
///
/// See [PackedBitmapDecoder] for details.
const packedBitmapDecoder = PackedBitmapDecoder._();

/// Decodes a bitmap from a compact (packed) binary format.
///
/// A `0` bit represents [PixelFormat.zero], and a `1` bit is [PixelFormat.max];
/// 32 values are packed into a single byte, with the least significant bit
/// representing the first value. The first two 32-bit words of the input are
/// the width and height of the bitmap, respectively.
final class PackedBitmapDecoder extends Converter<List<int>, Buffer<int>> {
  const PackedBitmapDecoder._();

  @override
  Buffer<int> convert(
    List<int> input, {
    PixelFormat<int, void> format = abgr8888,
  }) {
    final Uint32List view;
    if (input is TypedDataList<int>) {
      view = input.buffer.asUint32List();
    } else {
      view = Uint32List.fromList(input);
    }
    final width = view[0];
    final height = view[1];
    final output = IntPixels(width, height, format: format);

    // Reverse of the above encoding.
    var word = 0;
    var bit = 0;
    var offset = 2;
    for (var i = 0; i < output.data.length; i++) {
      if (bit == 0) {
        word = view[offset];
        offset++;
      }
      output.data[i] = (word & 1) == 0 ? format.zero : format.max;
      word >>= 1;
      bit++;
      if (bit == 32) {
        bit = 0;
      }
    }

    return output;
  }
}
