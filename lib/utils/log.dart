void logError(Object e, [StackTrace? stackTrace]) {
  print(e.toString());
  if (stackTrace != null) print(stackTrace);
}

void logInfo(Object obj) {
  print(obj);
}