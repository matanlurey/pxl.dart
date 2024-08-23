/// Fixed-size buffer of [Pixels], with customizable [PixelFormat]s,
/// [BlendMode]s, and more.
///
/// - Create and manipulate in-memory [IntPixels] or [FloatPixels] buffers
/// - Define[^1] and convert between [PixelFormat]s.
/// - Palette-based indexed pixel formats with [IndexedFormat].
/// - Buffer-to-buffer blitting with automatic format conversion and
///   [BlendMode]s.
/// - Region-based pixel manipulation, replacement, and copying.
///
/// [^1]: As of the alpha release, only predefined pixel formats are supported.
///
/// <!--
/// @docImport 'package:pxl/pxl.dart';
/// -->
library;

export 'package:pxl/src/blend.dart';
export 'package:pxl/src/buffer.dart';
export 'package:pxl/src/format.dart';
export 'package:pxl/src/geometry.dart';
