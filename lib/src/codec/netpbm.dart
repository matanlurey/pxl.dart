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
    final format = _getOrInferFormat(input);
    final output = StringBuffer('${format._ascii}\n');
    output.writeAll(comments.map((c) => '# $c\n'));
    output.writeln('${input.width} ${input.height}');

    final String Function(int) describe;
    switch (format) {
      case NetpbmFormat.bitmap:
        describe = (pixel) => pixel == input.format.zero ? '0' : '1';
      case NetpbmFormat.graymap:
        output.writeln(gray8.maxGray);
        describe = (pixel) {
          final gray = gray8.convert(pixel, from: input.format);
          return gray.toString().padLeft(3);
        };
      case NetpbmFormat.pixmap:
        output.writeln(rgb888.maxRed);
        describe = (pixel) {
          final rgb = rgb888.convert(pixel, from: input.format);
          final red = rgb888.getRed(rgb).toString().padLeft(3);
          final green = rgb888.getGreen(rgb).toString().padLeft(3);
          final blue = rgb888.getBlue(rgb).toString().padLeft(3);
          return '$red $green $blue';
        };
    }

    for (var y = 0; y < input.height; y++) {
      for (var x = 0; x < input.width; x++) {
        final pixel = input.getUnsafe(Pos(x, y));
        output.write(describe(pixel));
        if (x < input.width - 1) {
          output.write(' ');
        }
      }
      if (y < input.height - 1) {
        output.writeln();
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
  Uint8List convert(
    Buffer<int> input, {
    Iterable<String> comments = const [],
  }) {
    final format = _getOrInferFormat(input);
    final output = StringBuffer('${format._binary}\n');
    output.writeAll(comments.map((c) => '# $c\n'));
    output.writeln('${input.width} ${input.height}');

    final buffer = BytesBuilder(copy: false);
    final void Function(int) write;
    switch (format) {
      case NetpbmFormat.bitmap:
        output.write('1\n');
        write = (pixel) {
          buffer.addByte(pixel == input.format.zero ? 0 : 1);
        };
      case NetpbmFormat.graymap:
        output.write('${gray8.maxGray}\n');
        write = (pixel) {
          final gray = gray8.convert(pixel, from: input.format);
          buffer.addByte(gray);
        };
      case NetpbmFormat.pixmap:
        output.write('${rgb888.maxRed}\n');
        write = (pixel) {
          final rgb = rgb888.convert(pixel, from: input.format);
          buffer.addByte(rgb888.getRed(rgb));
          buffer.addByte(rgb888.getGreen(rgb));
          buffer.addByte(rgb888.getBlue(rgb));
        };
    }
    buffer.add(utf8.encode(output.toString()));

    for (var y = 0; y < input.height; y++) {
      for (var x = 0; x < input.width; x++) {
        final pixel = input.getUnsafe(Pos(x, y));
        write(pixel);
      }
    }

    return buffer.toBytes();
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
}

/// Decodes a portable pixmap (Netpbm) image format using ASCII to pixel data.
///
/// {@category Output and Comparison}
final class NetpbmAsciiDecoder extends NetpbmDecoder<String> {
  /// Creates a new ASCII Netpbm decoder with the given [format].
  const NetpbmAsciiDecoder({super.format});

  @override
  Buffer<int> convert(String input) {
    final NetpbmFormat format;
    final lines = const LineSplitter()
        .convert(input)
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .iterator;

    if (!lines.moveNext()) {
      throw FormatException('Invalid Netpbm image: missing format');
    }
    final header = lines.current.trim();
    switch (header) {
      case 'P1':
        format = NetpbmFormat.bitmap;
      case 'P2':
        format = NetpbmFormat.graymap;
      case 'P3':
        format = NetpbmFormat.pixmap;
      default:
        throw FormatException(
          'Invalid Netpbm image: unsupported format',
          header,
        );
    }

    if (!lines.moveNext()) {
      throw FormatException('Invalid Netpbm image: missing dimensions');
    }

    final dimensions = lines.current.split(' ');
    if (dimensions.length != 2) {
      throw FormatException(
        'Invalid Netpbm image: invalid dimensions',
        dimensions,
      );
    }

    final width = int.tryParse(dimensions[0]);
    final height = int.tryParse(dimensions[1]);
    if (width == null || height == null || width < 1 || height < 1) {
      throw FormatException(
        'Invalid Netpbm image: invalid dimensions',
        dimensions,
      );
    }

    final buffer = IntPixels(width, height, format: this.format);

    // Skip the optional maximum value if present.
    if (format != NetpbmFormat.bitmap && lines.moveNext()) {
      final max = int.tryParse(lines.current);
      if (max == null || max < 1) {
        throw FormatException(
          'Invalid Netpbm image: invalid maximum value',
          lines.current,
        );
      }
    }

    // Keep parsing pixels until the end of the image, skipping whitespace.
    var offset = 0;
    while (lines.moveNext()) {
      final line = lines.current;
      final values = line
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ')
          .split(' ')
          .map(int.tryParse)
          .toList();
      if (values.any((v) => v == null)) {
        throw FormatException(
          'Invalid Netpbm image: invalid pixel value(s)',
          line,
        );
      }

      final Iterable<int> pixels;
      switch (format) {
        case NetpbmFormat.bitmap:
          pixels = values.map(
            (v) => v == 0 ? this.format.zero : this.format.max,
          );
        case NetpbmFormat.graymap:
          pixels = values.map((v) {
            final gray = gray8.create(gray: v);
            return this.format.convert(gray, from: gray8);
          });
        case NetpbmFormat.pixmap:
          if (values.length % 3 != 0) {
            throw FormatException(
              'Invalid Netpbm image: invalid pixel count',
              line,
            );
          }
          pixels = Iterable.generate(
            values.length ~/ 3,
            (i) {
              final offset = i * 3;
              final rgb = abgr8888.create(
                red: values[offset],
                green: values[offset + 1],
                blue: values[offset + 2],
              );
              return this.format.convert(rgb, from: abgr8888);
            },
          );
      }

      buffer.data.setAll(offset, pixels);
      offset += pixels.length;
    }

    return buffer;
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
}
