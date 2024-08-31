import 'package:pxl/pxl.dart';

import '../src/prelude.dart';

void main() {
  test('encodes a 128x128 image compactly', () {
    final input = IntPixels(128, 128);

    // Fill every other pixel with white.
    for (var i = 0; i < input.data.length; i += 2) {
      input.data[i] = abgr8888.white;
    }

    final encoded = packedBitmapCodec.encoder.convert(input);
    check(encoded).deepEquals([
      128, 128, // Width and height.
      ...Iterable.generate(128 * 128 ~/ 32, (i) => 0x55555555),
    ]);

    final decoded = packedBitmapCodec.decoder.convert(encoded);
    check(decoded.compare(input).difference).equals(0);
  });
}
