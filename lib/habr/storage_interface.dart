import 'package:flutter/cupertino.dart';

import 'dto.dart';
import 'package:habr_app/utils/either.dart';

enum ErrorType {
  BadRequest,
  NotFound,
}

class StorageError {
  final ErrorType errCode;
  final String message;

  const StorageError({
    @required this.errCode,
    this.message,
  });
}

abstract class IStorage {
  Future<Either<StorageError, PostPreviews>> posts({int page});
  Future<Either<StorageError, Post>> article(String id);
  Future<Either<StorageError, Comments>> comments(String articleId);
}