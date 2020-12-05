abstract class Filter<T> {
  const Filter();

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

/// Default Filter all return false
class NoneFilter<T> extends Filter<T> {
  const NoneFilter();

  @override
  bool filter(T obj) => false;
}
