import 'package:collection/collection.dart';

extension Inverse<K, V> on Map<K, V> {
  /// Inverts all of the key-value pairs in the Map.
  /// If there are duplicate values, they just get overwritten.
  Map<V, K> inverse() {
    return map<V, K>((k, v) => MapEntry(v, k));
  }
}

extension Sort<K, V> on Map<K, V> {
  /// Returns a sorted version of the Map.
  /// Specify a [compare] function that works like the [compare] function in `List.sort()`.
  Map<K, V> sorted(int Function(MapEntry<K, V> a, MapEntry<K, V> b) compare) {
    return {
      for (final e in entries.toList().sorted(compare)) e.key: e.value,
    };
  }
}
