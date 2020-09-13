import 'dto.dart';
import 'package:either_dart/either.dart';

enum ErrorType {
  BadRequest,
  NotFound,
}

class StorageError {
  final ErrorType errCode;
  final String message;

  const StorageError({
    this.errCode,
    this.message,
  });
}

abstract class IStorage {
  Future<Either<StorageError, PostPreviews>> posts({int page});
  Future<Either<StorageError, Post>> article(String id);
  Future<Either<StorageError, Comments>> comments(String articleId);
}