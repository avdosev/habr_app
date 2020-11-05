abstract class Filter<T> {
  /// Check need to filter the object
  bool filter(T obj);
}

class AnyFilterCombine<T> extends Filter<T> {
  final List<Filter<T>> filters;
  AnyFilterCombine(this.filters);

  bool filter(T obj) {
    return filters.any((filter) => filter.filter(obj));
  }
}

class AllFilterCombine<T> extends Filter<T> {
  final List<Filter<T>> filters;
  AllFilterCombine(this.filters);

  bool filter(T obj) {
    return filters.every((filter) => filter.filter(obj));
  }
}
