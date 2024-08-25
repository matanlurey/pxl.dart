# pxl

A tiny cross-platform pixel buffer and foundation for pixel-based graphics.

## Usage

```dart
import 'package:pxl/pxl.dart';
```

## Features

![Example](https://github.com/user-attachments/assets/5d8a97c5-d9d8-4c60-852c-bfd043f1634b)

- Create and manipulate in-memory integer or floating-point pixel buffers.
- Define and convert between pixel formats.
- Palette-based indexed pixel formats.
- Buffer-to-buffer blitting with automatic format conversion and blend modes.
- Region-based pixel manipulation, replacement, and copying.

## Contributing

To run the tests, run:

```shell
dart test
```

To check code coverage locally, run:

```shell
./chore coverage
```

To preview `dartdoc` output locally, run:

```shell
./chore dartodc
```

### Inspiration and Sources

- [`MTLPixelFormat`](https://developer.apple.com/documentation/metal/mtlpixelformat)
- [`@thi.ng/pixel`](https://github.com/thi-ng/umbrella/tree/main/packages/pixel)
- [`embedded-graphics`](https://crates.io/crates/embedded-graphics)
- <https://www.da.vidbuchanan.co.uk/blog/hello-png.html>
