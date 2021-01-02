enum ErrorType {
  BadRequest,
  BadResponse,
  ServerError,
  NotFound,
  NotCached
}

class AppError {
  final ErrorType errCode;
  final String message;

  const AppError({
    this.errCode,
    this.message,
  });

  @override
  String toString() {
    if (message == null || message.isEmpty) {
      return errCode.toString();
    }
    return "$errCode: $message";
  }
}