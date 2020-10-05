import 'package:habr_app/habr/storage_interface.dart';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'log.dart';
import 'dart:convert';

Future<Either<StorageError, http.Response>> safe(Future<http.Response> request) async {
  try {
    return Right(await request);
  } catch (e) {
    logError(e);
    return Left(
        StorageError(
            errCode: ErrorType.BadRequest,
            message: "Request executing with errors")
    );
  }
}

Either<StorageError, http.Response> checkHttpStatus(http.Response response) {
  if (response.statusCode == 200)
    return Right(response);
  else
    return Left(
        StorageError(
          errCode: ErrorType.BadResponse,
          message: "Bad http status ${response.statusCode}"
        )
    );
}

dynamic parseJson(http.Response response) {
  return json.decode(response.body);
}