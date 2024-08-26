A [PixelFormat][] is a description of how pixel data is stored in memory. It
includes a set of standard properties and rules for how to interpret the data,
such as how many bytes are used to store each pixel, canonical (`zero` or `max`)
values, and conversion rules to and from other formats.

Pxl ships with a number of built-in pixel formats, and can be extended with
additional formats:

```dart
const myFormat = const MyFormat._();

//                         Pixel data type    Channel data type
//                                       v    v
final class MyFormat extends PixelFormat<int, int> {
  const MyFormat._();

  @override
  int get bytesPerPixel => 4;

  @override
  int get zero => 0;

  // ... rest of the class implementation
}
```

[PixelFormat]: ../pxl/PixelFormat-class.html

## Integer pixel formats

All integer formats use the ABGR 32-bit format as a common intermediate for
conversions; channels that are larger or smaller than 8 bits are scaled to fit
within the 8-bit range. For example a 4-bit channel value of `0x0F` would be
scaled to `0xFF` when converting to 8-bit.

Name         | Bits per pixel | Description
------------ | -------------- | ------------------------------------------------
[abgr8888][] | 32             | 4 channels @ 8 bits each
[argb8888][] | 32             | 4 channels @ 8 bits each
[gray8][]    | 8              | 1 channel @ 8 bits
[rgba8888][] | 32             | 4 channels @ 8 bits each

[abgr8888]: ../pxl/abgr8888-constant.html
[argb8888]: ../pxl/argb8888-constant.html
[gray8]: ../pxl/gray8-constant.html
[rgba8888]: ../pxl/rgba8888-constant.html

Grayscale formats use _luminance_ values to represent color.

## Floating-point pixel formats

All floating-point formats use the RGBA 128-bit format as a common intermediate
for conversions; channels that are larger or smaller than 32 bits are scaled to
fit within the 32-bit range. When converting to packed integer formats, data is
normalized to the range `[0.0, 1.0]` and then scaled to fit within the integer
range.

Name          | Bits per pixel | Description
------------- | -------------- | -----------------------------------------------
[floatRgba][] | 128            | Red, Green, Blue, Alpha

[floatRgba]: ../pxl/floatRgba-constant.html

## Indexed pixel formats

[IndexedFormat][]s use a palette to map pixel values to colors.

The palette is stored as a separate array of colors, and the pixel data is
stored as indices into the palette.

```dart
// Example of a 1-bit indexed format.
final mono1 = IndexedPixelFormat.bits8(
  const [0xFF000000, 0xFFFFFFFF],
  format: abgr8888,
);
```

Name          | Bits per pixel | Description
------------- | -------------- | -----------------------------------------------
[system8][]   | 8              | 8 colors.
[system256][] | 8              | 256 colors (216 RGB + 40 grayscale).

[IndexedFormat]: ../pxl/IndexedFormat-class.html
[system8]: ../pxl/system8.html
[system256]: ../pxl/system256.html
