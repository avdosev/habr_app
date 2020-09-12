/// Represents a value of one of two possible types (a disjoint union).
/// Instances of [Either] are either an instance of [Left] or [Right].
/// FP Convention dictates that:
///   [Left] is used for "failure".
///   [Right] is used for "success".
abstract class Either<L, R> {
  /// Represents the left side of [Either] class which by convention is a "Failure".
  bool get isLeft => this is Left<L, R>;

  /// Represents the right side of [Either] class which by convention is a "Success"
  bool get isRight => this is Right<L, R>;

  L get left {
    if (this is Left<L, R>)
      return (this as Left<L, R>).value;
    else
      throw Exception('Illegal use. You should check isLeft() before calling ');
  }

  R get right {
    if (this is Right<L, R>)
      return (this as Right<L, R>).value;
    else
      throw Exception('Illegal use. You should check isRight() before calling');
  }

  Either<TL, TR> either<TL, TR>(TL Function(L) fnL, TR Function(R) fnR);
  Either<L, TR> then<TR>(Either<L, TR> Function(R) fnR);
  Either<L, TR> map<TR>(TR Function(R) fnR);
  T unit<T>(T Function(L) fnL, T Function(R) fnR);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);

  @override
  Either<TL, TR> either<TL, TR>(TL Function(L) fnL, TR Function(R) fnR) {
    return Left<TL, TR>(fnL(value));
  }

  @override
  Either<L, TR> then<TR>(Either<L, TR> Function(R) fnR) {
    return Left<L, TR>(value);
  }

  @override
  Either<L, TR> map<TR>(TR Function(R) fnR) {
    return Left<L, TR>(value);
  }

  @override
  T unit<T>(T Function(L) fnL, T Function(R) fnR) {
    return fnL(value);
  }

}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);

  @override
  Either<TL, TR> either<TL, TR>(TL Function(L) fnL, TR Function(R) fnR) {
    return Right<TL, TR>(fnR(value));
  }

  @override
  Either<L, TR> then<TR>(Either<L, TR> Function(R) fnR) {
    return fnR(value);
  }

  @override
  Either<L, TR> map<TR>(TR Function(R) fnR) {
    return Right<L, TR>(fnR(value));
  }

  @override
  T unit<T>(T Function(L) fnL, T Function(R) fnR) {
    return fnR(value);
  }

}