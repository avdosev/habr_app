import 'package:habr_app/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'log.dart';
import 'dart:convert';

Future<Either<AppError, http.Response>> safe(Future<http.Response> request) async {
  try {
    return Right(await request);
  } catch (e) {
    logError(e);
    return Left(
        AppError(
            errCode: ErrorType.BadRequest,
            message: "Request executing with errors")
    );
  }
}

Either<AppError, http.Response> checkHttpStatus(http.Response response) {
  if (response.statusCode == 200)
    return Right(response);
  else
    return Left(
        AppError(
          errCode: ErrorType.BadResponse,
          message: "Bad http status ${response.statusCode}"
        )
    );
}

dynamic parseJson(http.Response response) {
  return json.decode(response.body);
}