# pxl

A tiny cross-platform pixel buffer and foundation for pixel-based graphics.

<!--
[![Mirage on pub.dev][pub_img]][pub_url]
-->
[![Code coverage][cov_img]][cov_url]
[![Github action status][gha_img]][gha_url]
[![Dartdocs][doc_img]][doc_url]
[![Style guide][sty_img]][sty_url]

<!--
[pub_url]: https://pub.dartlang.org/packages/chaos
[pub_img]: https://img.shields.io/pub/v/pxl.svg
-->
[gha_url]: https://github.com/matanlurey/pxl.dart/actions
[gha_img]: https://github.com/matanlurey/pxl.dart/actions/workflows/check.yaml/badge.svg
[cov_url]: https://coveralls.io/github/matanlurey/pxl.dart?branch=main
[cov_img]: https://coveralls.io/repos/github/matanlurey/pxl.dart/badge.svg?branch=main
[doc_url]: https://matanlurey.github.io/pxl.dart/
<!--
[doc_url]: https://www.dartdocs.org/documentation/pxl/latest
-->
[doc_img]: https://img.shields.io/badge/Documentation-latest-blue.svg
[sty_url]: https://pub.dev/packages/oath
[sty_img]: https://img.shields.io/badge/style-oath-9cf.svg

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
