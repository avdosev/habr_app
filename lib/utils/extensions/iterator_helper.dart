import 'package:tuple/tuple.dart';

extension IteratorHelper<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T item) f) {
    var index = 0;
    return map<E>((T item) => f(index++, item));
  }
}

Iterable<Tuple2<T1, T2>> zip2<T1, T2>(
    Iterable<T1> it1, Iterable<T2> it2) sync* {
  final iter1 = it1.iterator;
  final iter2 = it2.iterator;
  bool keep_running = true;
  while (keep_running) {
    yield Tuple2<T1, T2>(iter1.current, iter2.current);
    final move1 = iter1.moveNext();
    final move2 = iter2.moveNext();
    assert(move1 ^ move2);
    keep_running = move1 && move2;
  }
}
