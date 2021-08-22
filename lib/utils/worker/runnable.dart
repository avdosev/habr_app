import 'dart:async';

typedef Fun<ArgT, OutT> = FutureOr<OutT> Function(ArgT arg);

class Runnable<A, O> {
  final A arg;
  final Fun<A, O> fun;

  Runnable({
    required this.arg,
    required this.fun,
  });

  FutureOr<O> call() {
    return fun(arg);
  }
}
