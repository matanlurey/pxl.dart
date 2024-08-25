The [BlendMode] interface generates a function that blends two pixel values
together:

```dart
// Combine non-overlapping regions of colors.
final xor = BlendMode.xor.getBlend(abgr8888, abgr8888);
print(xor(0x00000000, 0xFFFFFFFF)); // 0xFFFFFFFF
```

[BlendMode]: ../pxl/BlendMode-class.html

Default blend modes are provided using the [PorterDuff] constructor:

```dart
const BlendMode srcIn = PorterDuff(
  PorterDuff.dst,
  PorterDuff.zero,
);
```

Blend Mode | Description
---------- | -----------
[clear][]  | Sets pixels to `zero`.
[src][]    | Copies the source pixel.
[dst][]    | Copies the destination pixel.
[srcIn][]  | The source that overlaps the destination replaces the destination.
[dstIn][]  | The destination that overlaps the source replaces the source.
[srcOut][] | The source that does not overlap the destination replaces the destination.
[dstOut][] | The destination that does not overlap the source replaces the source.
[srcAtop][]| The source that overlaps the destination is blended with the destination.
[dstAtop][]| The destination that overlaps the source is blended with the source.
[xor][]    | The source and destination are combined where they do not overlap.
[plus][]   | The source and destination are added together.

[PorterDuff]: ../pxl/PorterDuff-class.html

[clear]: ../pxl/BlendMode/clear-constant.html
[src]: ../pxl/BlendMode/src-constant.html
[dst]: ../pxl/BlendMode/dst-constant.html
[srcIn]: ../pxl/BlendMode/srcIn-constant.html
[dstIn]: ../pxl/BlendMode/dstIn-constant.html
[srcOut]: ../pxl/BlendMode/srcOut-constant.html
[dstOut]: ../pxl/BlendMode/dstOut-constant.html
[srcAtop]: ../pxl/BlendMode/srcAtop-constant.html
[dstAtop]: ../pxl/BlendMode/dstAtop-constant.html
[xor]: ../pxl/BlendMode/xor-constant.html
[plus]: ../pxl/BlendMode/plus-constant.html
