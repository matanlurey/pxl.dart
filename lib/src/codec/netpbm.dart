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
  bitmap,

  /// Portable Graymap (PGM) format.
  ///
  /// Each pixel representing a grayscale value.
  graymap,

  /// Portable Pixmap (PPM) format.
  ///
  /// Each _three_ pixels representing RGB color values.
  pixmap;
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
  T convert(Buffer<int> input, {Iterable<String> comments = const []}) {
    final format = _getOrInferFormat(input);
    final header = NetpbmHeader(
      width: input.width,
      height: input.height,
      max: switch (format) {
        NetpbmFormat.bitmap => null,
        NetpbmFormat.graymap => gray8.maxGray,
        NetpbmFormat.pixmap => rgb888.maxRed,
      },
      format: format,
      comments: comments,
    );
    final Iterable<int> pixels;
    switch (format) {
      case NetpbmFormat.bitmap:
        pixels = input.data.map((value) {
          return value == input.format.zero ? 0 : 1;
        });
      case NetpbmFormat.graymap:
        pixels = input.data.map((value) {
          return gray8.convert(value, from: input.format);
        });
      case NetpbmFormat.pixmap:
        pixels = input.data.map((value) {
          final rgb = rgb888.convert(value, from: input.format);
          return [
            rgb888.getRed(rgb),
            rgb888.getGreen(rgb),
            rgb888.getBlue(rgb),
          ];
        }).expand((p) => p);
    }
    return _convert(header, pixels);
  }

  T _convert(NetpbmHeader header, Iterable<int> pixels);

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
  String _convert(NetpbmHeader header, Iterable<int> pixels) {
    final output = StringBuffer();
    output.writeln('P${header.format.index + 1}');
    for (final comment in header.comments) {
      output.writeln('# $comment');
    }
    output.writeln('${header.width} ${header.height}');
    var padding = 1;
    if (header.max case final max?) {
      output.writeln(max);
      padding = '$max'.length;
    }
    var i = 0;
    for (final pixel in pixels) {
      output.write('$pixel'.padLeft(padding));
      if (++i % header.width == 0) {
        if (i < pixels.length) {
          output.writeln();
        }
      } else {
        output.write(' ');
      }
    }
    return output.toString();
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
  Uint8List _convert(NetpbmHeader header, Iterable<int> pixels) {
    final output = BytesBuilder(copy: false);
    output.add(utf8.encode('P${header.format.index + 4}\n'));
    for (final comment in header.comments) {
      output.add(utf8.encode('# $comment\n'));
    }
    output.add(utf8.encode('${header.width} ${header.height}\n'));
    if (header.max case final max?) {
      output.add(utf8.encode('$max\n'));
    }
    for (final pixel in pixels) {
      output.addByte(pixel);
    }
    return output.toBytes();
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

  /// Returns the length of the input.
  @protected
  int _lengthOf(T input);

  /// Returns the byte at the given index in the input.
  @protected
  int _byteAt(T input, int index);

  static bool _isLinebreak(int byte) => byte == 0x0A;

  static bool _isWhitespace(int byte) {
    return byte == 0x20 || byte >= 0x09 && byte <= 0x0D;
  }

  /// Reads the input until a test is met.
  @nonVirtual
  @protected
  (String, int) _readUntil(
    T input,
    int start, [
    bool Function(int) test = _isLinebreak,
  ]) {
    final result = StringBuffer();
    for (; start < _lengthOf(input); start++) {
      final byte = _byteAt(input, start);
      if (test(byte)) {
        start++;
        break;
      }
      result.writeCharCode(byte);
    }
    return (result.toString(), start);
  }

  /// Reads comments from the input.
  ///
  /// Returns the index after the comments.
  @nonVirtual
  @protected
  int _readComments(T input, List<String> output, int start) {
    while (_byteAt(input, start) == 0x23) {
      final (comment, next) = _readUntil(input, start + 1);

      // Check for and throw if EOF.
      if (next == _lengthOf(input)) {
        throw FormatException('Unexpected EOF', input, start);
      }

      output.add(comment.substring(1).trim());
      start = next;
    }
    return start;
  }

  /// Parses the header information from the Netpbm image.
  ///
  /// Returns the header, error message, and the offset after the header.
  @protected
  @nonVirtual
  (NetpbmHeader? head, String error, int start) _parseHeader(T input) {
    final NetpbmFormat format;
    final int width;
    final int height;
    final comments = <String>[];
    int? max;

    // Read leading comments.
    var start = _readComments(input, comments, 0);

    // Read the format.
    final String magic;
    (magic, start) = _readUntil(input, start);
    switch (magic) {
      case 'P1' when this is NetpbmAsciiDecoder:
        format = NetpbmFormat.bitmap;
      case 'P4' when this is NetpbmBinaryDecoder:
        format = NetpbmFormat.bitmap;
      case 'P2' when this is NetpbmAsciiDecoder:
        format = NetpbmFormat.graymap;
      case 'P5' when this is NetpbmBinaryDecoder:
        format = NetpbmFormat.graymap;
      case 'P3' when this is NetpbmAsciiDecoder:
        format = NetpbmFormat.pixmap;
      case 'P6' when this is NetpbmBinaryDecoder:
        format = NetpbmFormat.pixmap;
      default:
        return (null, 'Invalid header format: $magic', start);
    }

    // Read comments after the format.
    start = _readComments(input, comments, start);

    // Read the width and height.
    final String widthStr;
    (widthStr, start) = _readUntil(input, start, _isWhitespace);
    final String heightStr;
    (heightStr, start) = _readUntil(input, start, _isWhitespace);

    // Parse the width and height.
    if (int.tryParse(widthStr) case final value?) {
      width = value;
    } else {
      return (null, 'Invalid width: $widthStr', start);
    }

    if (int.tryParse(heightStr) case final value?) {
      height = value;
    } else {
      return (null, 'Invalid height: $heightStr', start);
    }

    // Read the maximum value if not a bitmap.
    if (format != NetpbmFormat.bitmap) {
      final String maxStr;
      (maxStr, start) = _readUntil(input, start);
      if (int.tryParse(maxStr) case final value?) {
        max = value;
      } else if (maxStr.isNotEmpty) {
        return (null, 'Invalid max value: $maxStr', start);
      }
    }

    return (
      NetpbmHeader(
        format: format,
        width: width,
        height: height,
        max: max,
        comments: comments,
      ),
      '',
      start
    );
  }

  /// Returns the pixels from the input starting at the given offset.
  @protected
  List<int> _data(T input, int offset, {required bool bitmap});

  @override
  @nonVirtual
  Buffer<int> convert(T input) {
    final (header, error, offset) = _parseHeader(input);
    if (header == null) {
      throw FormatException(error, input);
    }
    final data = _data(
      input,
      offset,
      bitmap: header.format == NetpbmFormat.bitmap,
    );
    final Iterable<int> pixels;
    switch (header.format) {
      case NetpbmFormat.bitmap:
        pixels = data.map((value) {
          return value == 0x0 ? format.zero : format.max;
        });
      case NetpbmFormat.graymap:
        pixels = data.map((value) {
          final gray = gray8.create(gray: value);
          return format.convert(gray, from: gray8);
        });
      case NetpbmFormat.pixmap:
        if (data.length % 3 != 0) {
          throw FormatException('Invalid pixel data', input, offset);
        }
        pixels = Iterable.generate(data.length ~/ 3, (i) {
          final r = data[i * 3];
          final g = data[i * 3 + 1];
          final b = data[i * 3 + 2];
          final rgb = rgb888.create(red: r, green: g, blue: b);
          return format.convert(rgb, from: rgb888);
        });
    }

    final buffer = IntPixels(header.width, header.height, format: format);
    buffer.data.setAll(0, pixels);
    return buffer;
  }
}

/// Decodes a portable pixmap (Netpbm) image format using ASCII to pixel data.
///
/// {@category Output and Comparison}
final class NetpbmAsciiDecoder extends NetpbmDecoder<String> {
  /// Creates a new ASCII Netpbm decoder with the given [format].
  const NetpbmAsciiDecoder({super.format});

  @override
  int _lengthOf(String input) => input.length;

  @override
  int _byteAt(String input, int index) => input.codeUnitAt(index);

  @override
  List<int> _data(String input, int offset, {required bool bitmap}) {
    final result = <int>[];

    // For Bitmaps, whitespace is optional, that is:
    // 0 0 1
    // 1 0 1
    //
    // or:
    // 001101
    //
    // Are equally valid.
    //
    // For the other formats, whitespace separates the pixel values.
    // 255 0 255

    if (bitmap) {
      for (var i = offset; i < input.length; i++) {
        final byte = _byteAt(input, i);
        if (byte == 0x30) {
          result.add(0);
        } else if (byte == 0x31) {
          result.add(1);
        } else if (NetpbmDecoder._isWhitespace(byte)) {
          continue;
        } else {
          throw FormatException('Invalid pixel value', input, i);
        }
      }
    } else {
      while (offset < input.length) {
        final (pixel, next) = _readUntil(
          input,
          offset,
          NetpbmDecoder._isWhitespace,
        );
        if (pixel.isEmpty) {
          offset = next;
          continue;
        }
        if (int.tryParse(pixel) case final value?) {
          result.add(value);
        } else {
          throw FormatException('Invalid pixel value: $pixel', input, offset);
        }
        offset = next;
      }
    }

    return result;
  }
}

/// Decodes a portable pixmap (Netpbm) image format using binary to pixel data.
///
/// {@category Output and Comparison}
final class NetpbmBinaryDecoder extends NetpbmDecoder<Uint8List> {
  /// Creates a new binary Netpbm decoder with the given [format].
  const NetpbmBinaryDecoder({super.format});

  @override
  int _lengthOf(Uint8List input) => input.length;

  @override
  int _byteAt(Uint8List input, int index) => input[index];

  @override
  List<int> _data(Uint8List input, int offset, {required bool bitmap}) {
    return Uint8List.view(input.buffer, offset);
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
