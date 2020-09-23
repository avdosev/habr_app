import 'dto.dart';
import 'package:either_dart/either.dart';

enum ErrorType {
  BadRequest,
  BadResponse,
  ServerError,
  NotFound,
  NotCached
}

class StorageError {
  final ErrorType errCode;
  final String message;

  const StorageError({
    this.errCode,
    this.message,
  });
}