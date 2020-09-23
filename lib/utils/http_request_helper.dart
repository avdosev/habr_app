import 'package:habr_app/habr/storage_interface.dart';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'log.dart';

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