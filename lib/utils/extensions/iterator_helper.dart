extension IteratorHelper<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(
      E Function(int index, T item) f) {
    var index = 0;
    return map<E>((T item) => f(index++, item));
  }
}