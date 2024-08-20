import 'dart:typed_data';

/// Whether the current runtime is JavaScript.
const isJsRuntime = identical(1, 1.0);

/// Disables bounds checking for the given function.
const unsafeNoBoundsChecks = isJsRuntime
    ? pragma('dart2js:index-bounds:trust')
    : pragma('vm:unsafe:no-bounds-checks');

/// Creates a buffer of integers with the given [bytes] and [length].
///
/// The buffer is created with the smallest integer type that can hold [bytes]
/// bits, and has [length] elements.
TypedDataList<int> newIntBuffer({required int bytes, required int length}) {
  return switch (bytes) {
    <= 1 => Uint8List(length),
    <= 2 => Uint16List(length),
    <= 4 => Uint32List(length),
    _ => throw StateError('Unsupported integer size: $bytes'),
  };
}
