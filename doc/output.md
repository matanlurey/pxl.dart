Pxl is a headless pixel manipulation library, and provides limited support for
rendering, expecting the user to provide their own rendering solution (any
`Canvas`-like API will do, or something that supports pixel buffers in one of
the many formats Pxl provides).

To aid with testing and debugging, Pxl provides a few useful utilities.

## Comparisons

Two buffers can be compared for differences using the `compare` method:

```dart
final diff = pixels1.compare(pixels2);
print(diff);
```

The `compare` method returns a `Comparison` object, which can be used to
summarize, iterate, or visualize the differences between two buffers. Pxl itself
uses this method in its test suite to compare expected and actual results for
pixel operations.

```dart
final diff = pixels1.compare(pixels2);
if (diff.difference < 0.01) {
  print('The buffers are nearly identical.');
} else {
  print('The buffers differ by ${diff.difference}.');
}
```

## Codecs

Converting pixel buffers to popular formats is best done with a full-featured
library like `image` or `dart:ui`, but Pxl provides a few simple codecs for
converting pixel buffers to pixel-based formats like [PFM][], [PBM][], and can
even output as an uncompressed PNG with [uncompressedPngEncoder][]:

```dart
import 'dart:io';

import 'package:pxl/pxl.dart';

void main() {
  final image = IntPixels(8, 8);
  image.fill(abgr8888.red);

  final bytes = uncompressedPngEncoder.convert(image);
  File('example.png').writeAsBytesSync(bytes);
}
```

[uncompressedPngEncoder]: ../pxl/uncompressedPngEncoder-constant.html
[PFM]: http://netpbm.sourceforge.net/doc/pfm.html
[PBM]: http://netpbm.sourceforge.net/doc/pbm.html
