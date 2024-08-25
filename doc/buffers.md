2-dimensional views of pixel data are provided by the [Buffer][] type, which
provides a read-only view, with similar functionality to an `Iterable`: it can
be extended or mixed-in as a base class provided the necessary methods are
implemented.

```dart
final class MyBuffer extends Buffer<int> {
  @override
  PixelFormat<int, void> get format => myFormat;

  @override
  int get width => 640;

  @override
  int get height => 480;

  /* ... rest of the class implementation ... */
}
```

[Buffer]: ../pxl/Buffer-class.html

In most cases, a concrete [Pixels][] instance will be used to represent pixel
data, which is a buffer that can be read from _and written to_ and guarantees
fast access to linearly stored pixel data. For example, the [IntPixels][] class
stores pixel data as a list of integers, and [FloatPixels][] stores pixel data
as a 32x4 matrix of floating-point values.

[Pixels]: ../pxl/Pixels-class.html
[IntPixels]: ../pxl/IntPixels-class.html
[FloatPixels]: ../pxl/FloatPixels-class.html

```dart
// Creating a 320x240 pixel buffer with the default `abgr8888` format.
final pixels = new IntPixels(320, 240);

// Setting the pixel at (10, 20) to red.
pixels.set(Pos(10, 20), abgr8888.red);
```

## Writing data

The `set` method is not the only way to write data to a buffer:

- [`clear`][]: Clears a region to the `zero` value.
- [`fill`][]: Fills a region with a pixel value.
- [`copyFrom`][]: Copies pixel data from another buffer.

[`clear`]: ../pxl/Pixels/clear.html
[`fill`]: ../pxl/Pixels/fill.html
[`copyFrom`]: ../pxl/Pixels/copyFrom.html

For example, to fill the entire buffer with red:

```dart
pixels.fill(abgr8888.red);
```

Pixels also support _alpha blending_; see [blending](./Blending-topic.html)
for more information.

## Reading data

Reading data from a buffer is done using the `get` method:

```dart
final pixel = pixels.get(Pos(10, 20));
```

The `get` method is not the only way to read data from a buffer:

- [`getRange`][]: Reads a range of pixels lazily.
- [`getRect`][]: Reads a rectangular region of pixels lazily.

[`getRange`]: ../pxl/Buffer/getRange.html
[`getRect`]: ../pxl/Buffer/getRect.html

## Converting data

Many operations in Pxl can automatically convert between different pixel formats
as needed.

To lazily convert buffers, use the `mapConvert` method:

```dart
final abgr8888Pixels = IntPixels(320, 240);
final rgba8888Buffer = abgr8888Pixels.mapConvert(rgba8888);
```

To copy the actual data, use [IntPixels.from][] or [FloatPixels.from][]:

```dart
final rgba8888Pixels = IntPixels.from(abgr8888Pixels);
```

[IntPixels.from]: ../pxl/IntPixels/IntPixels.from.html
[FloatPixels.from]: ../pxl/FloatPixels/FloatPixels.from.html
