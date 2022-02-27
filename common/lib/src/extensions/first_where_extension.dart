extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T e) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ListExtension<T> on List<T> {
  int? indexWhereOrNull(bool Function(T e) test) {
    int index = indexWhere(test);
    return index == -1 ? null : index;
  }
}
