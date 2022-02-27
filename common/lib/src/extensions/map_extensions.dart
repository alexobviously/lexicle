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
    Map<K, V> _sorted = {};
    List<MapEntry<K, V>> _entries = entries.toList()..sort(compare);
    for (final e in _entries) {
      _sorted[e.key] = e.value;
    }
    return _sorted;
  }
}
