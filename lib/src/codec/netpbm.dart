/// Inspired from <https://github.com/thi-ng/umbrella/tree/develop/packages/pixel-io-netpbm>.
///
/// See also:
/// - <https://en.wikipedia.org/wiki/Netpbm>
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pxl/pxl.dart';

/// Encodes pixel data as a portable pixmap (Netpbm) image format.
///
/// {@macro pxl.netpbm_encoder.format}
///
/// To specify the format explicitly, use [NetpbmBinaryEncoder.new].
///
/// {@category Output and Comparison}
const netpbmBinaryEncoder = NetpbmBinaryEncoder();

/// Encodes pixel data as a portable pixmap (Netpbm) image format using ASCII.
///
/// {@macro pxl.netpbm_encoder.format}
///
/// To specify the format explicitly, use [NetpbmAsciiEncoder.new].
///
/// {@category Output and Comparison}
const netpbmAsciiEncoder = NetpbmAsciiEncoder();

/// Decodes a portable pixmap (Netpbm) image format using binary to pixel data.
///
/// {@macro pxl.netpbm_decoder.pixel_format}
///
/// To specify the format explicitly, use [NetpbmBinaryDecoder.new].
///
/// {@category Output and Comparison}
const netpbmBinaryDecoder = NetpbmBinaryDecoder();

/// Decodes a portable pixmap (Netpbm) image format using ASCII to pixel data.
///
/// {@macro pxl.netpbm_decoder.pixel_format}
///
/// To specify the format explicitly, use [NetpbmAsciiDecoder.new].
///
/// {@category Output and Comparison}
const netpbmAsciiDecoder = NetpbmAsciiDecoder();

/// Formats supported by the Netpbm image format.
///
/// {@category Output and Comparison}
enum NetpbmFormat {
  /// Portable Bitmap (PBM) format.
  ///
  /// Each pixel representing one of two values, [PixelFormat.zero] and
  /// [PixelFormat.max].
  bitmap('P1', 'P4'),

  /// Portable Graymap (PGM) format.
  ///
  /// Each pixel representing a grayscale value.
  graymap('P2', 'P5'),

  /// Portable Pixmap (PPM) format.
  ///
  /// Each pixel representing RGB color values.
  pixmap('P3', 'P6');

  const NetpbmFormat(this._ascii, this._binary);

  /// ASCII representation of the format.
  final String _ascii;

  /// Binary representation of the format.
  final String _binary;
}

/// Encodes pixel data as a portable pixmap (Netpbm) image format.
///
/// {@category Output and Comparison}
abstract final class NetpbmEncoder<T> extends Converter<Buffer<int>, T> {
  /// @nodoc
  const NetpbmEncoder({required this.format});

  /// {@template pxl.netpbm_encoder.format}
  /// The format of the Netpbm image.
  ///
  /// If omitted, the format is inferred from the pixel data:
  /// - A format that implements [Grayscale] -> [NetpbmFormat.graymap].
  /// - A format that implements [Rgb] -> [NetpbmFormat.pixmap].
  /// - Otherwise, [NetpbmFormat.bitmap].
  /// {@endtemplate}
  final NetpbmFormat? format;

  @override
  T convert(Buffer<int> input, {Iterable<String> comments = const []});

  @protected
  NetpbmFormat _getOrInferFormat(Buffer<int> input) {
    if (input.width < 1) {
      throw ArgumentError.value(
        input.width,
        'input.width',
        'Must be greater than 0',
      );
    }
    if (input.height < 1) {
      throw ArgumentError.value(
        input.height,
        'input.height',
        'Must be greater than 0',
      );
    }
    if (format case final format?) {
      return format;
    }
    return switch (input.format) {
      Grayscale() => NetpbmFormat.graymap,
      Rgb() => NetpbmFormat.pixmap,
      _ => NetpbmFormat.bitmap,
    };
  }
}

/// Encodes pixel data in a portable pixmap (Netpbm) image format using ASCII.
///
/// A singleton instance of this class is available as [netpbmAsciiEncoder].
///
/// {@category Output and Comparison}
final class NetpbmAsciiEncoder extends NetpbmEncoder<String> {
  /// Creates a new ASCII Netpbm encoder with the given [format].
  const NetpbmAsciiEncoder({super.format});

  @override
  String convert(
    Buffer<int> input, {
    Iterable<String> comments = const [],
  }) {
    throw UnimplementedError();
  }
}

/// Encodes pixel data in a portable pixmap (Netpbm) image format using binary.
///
/// A singleton instance of this class is available as [netpbmBinaryEncoder].
///
/// {@category Output and Comparison}
final class NetpbmBinaryEncoder extends NetpbmEncoder<Uint8List> {
  /// Creates a new binary Netpbm encoder with the given [format].
  const NetpbmBinaryEncoder({super.format});

  @override
  Uint8List convert(
    Buffer<int> input, {
    Iterable<String> comments = const [],
  }) {
    throw UnimplementedError();
  }
}

/// Decodes a portable pixmap (Netpbm) image format to pixel data.
///
/// {@category Output and Comparison}
abstract final class NetpbmDecoder<T> extends Converter<T, Buffer<int>> {
  /// @nodoc
  const NetpbmDecoder({this.format = abgr8888});

  /// {@template pxl.netpbm_encoder.pixel_format}
  /// The pixel format of the decoded image.
  ///
  /// If omitted, the pixel format defauls to a fully opaque [abgr8888].
  /// {@endtemplate}
  final PixelFormat<int, void> format;

  /// Parses the header information from the Netpbm image.
  ///
  /// If the header is invalid or missing, a [FormatException] is thrown.
  NetpbmHeader parseHeader(T input) {
    final (header, error, offset) = _parseHeader(input);
    if (header == null) {
      throw FormatException(error, input);
    }
    return header;
  }

  /// Parses the header information from the Netpbm image.
  ///
  /// If the header is invalid or missing, `null` is returned.
  NetpbmHeader? tryParseHeader(T input) {
    return _parseHeader(input).$1;
  }

  (NetpbmHeader? head, String error, int start) _parseHeader(T input);
}

/// Decodes a portable pixmap (Netpbm) image format using ASCII to pixel data.
///
/// {@category Output and Comparison}
final class NetpbmAsciiDecoder extends NetpbmDecoder<String> {
  /// Creates a new ASCII Netpbm decoder with the given [format].
  const NetpbmAsciiDecoder({super.format});

  @override
  (NetpbmHeader? head, String error, int start) _parseHeader(String input) {
    throw UnimplementedError();
  }

  @override
  Buffer<int> convert(String input) {
    throw UnimplementedError();
  }
}

/// Decodes a portable pixmap (Netpbm) image format using binary to pixel data.
///
/// {@category Output and Comparison}
final class NetpbmBinaryDecoder extends NetpbmDecoder<Uint8List> {
  /// Creates a new binary Netpbm decoder with the given [format].
  const NetpbmBinaryDecoder({super.format});

  @override
  Buffer<int> convert(Uint8List input) {
    throw UnimplementedError();
  }

  static bool _isLinebreak(int byte) => byte == 0x0A;
  static bool _isWhitespace(int byte) {
    return byte == 0x20 || byte >= 0x09 && byte <= 0x0D;
  }

  (String, int) _readUntil(
    Uint8List input,
    int start, [
    bool Function(int) test = _isLinebreak,
  ]) {
    final result = StringBuffer();
    for (; start < input.length; start++) {
      final byte = input[start];
      if (test(byte)) {
        start++;
        break;
      }
      result.writeCharCode(byte);
    }
    return (result.toString(), start);
  }

  int _readComments(Uint8List input, List<String> output, int start) {
    while (input[start] == 0x23) {
      final (comment, next) = _readUntil(input, start + 1);

      // Check for and throw if EOF.
      if (next == input.length) {
        throw FormatException('Unexpected EOF', input, start);
      }

      output.add(comment);
      start = next;
    }
    return start;
  }

  @override
  (NetpbmHeader? head, String error, int start) _parseHeader(Uint8List input) {
    throw UnimplementedError();
  }
}

/// Parsed header information from a Netpbm image.
@immutable
final class NetpbmHeader {
  /// Creates a new Netpbm header with the given values.
  NetpbmHeader({
    required this.format,
    required this.width,
    required this.height,
    this.max,
    Iterable<String> comments = const [],
  }) : comments = List.unmodifiable(comments);

  /// The format of the Netpbm image.
  final NetpbmFormat format;

  /// The width of the image.
  final int width;

  /// The height of the image.
  final int height;

  /// The maximum value of a pixel in the image.
  final int? max;

  /// Comments associated with the image.
  final List<String> comments;

  @override
  bool operator ==(Object other) {
    if (other is! NetpbmHeader) {
      return false;
    }
    if (format != other.format) {
      return false;
    }
    if (width != other.width) {
      return false;
    }
    if (height != other.height) {
      return false;
    }
    if (max != other.max) {
      return false;
    }
    if (comments.length != other.comments.length) {
      return false;
    }
    for (var i = 0; i < comments.length; i++) {
      if (comments[i] != other.comments[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(format, width, height, max, Object.hashAll(comments));
  }

  @override
  String toString() {
    final buffer = StringBuffer('NetpbmHeader(\n');
    buffer.writeln('  format: $format,');
    buffer.writeln('  width: $width,');
    buffer.writeln('  height: $height,');
    buffer.writeln('  max: $max,');
    buffer.writeln('  comments: $comments,');
    buffer.write(')');
    return buffer.toString();
  }
}
