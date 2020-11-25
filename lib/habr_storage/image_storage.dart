import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/utils/http_request_helper.dart';
import 'cache_tables.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<String> _generateName(String url) async {
  final prefix = md5.convert(utf8.encode(url));
  return prefix.toString() + '_' + DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      '.' +
      url.split('.').last;
}

class ImageLocalStorage {
  final Cache _cache;
  String _path;

  ImageLocalStorage(this._cache);

  Future<String> get _localPath async {
    if (_path == null) {
      final directory = await getApplicationDocumentsDirectory();
      _path = directory.path;
    }

    return _path;
  }

  Future<String> _getImagePath(String url) async {
    final path = await _localPath;
    final filename = await _generateImageName(url);
    return '$path/$filename';
  }

  Future<String> _generateImageName(String url) {
    return compute(_generateName, url);
  }

  /// Return AppError or path to saved file
  Future<Either<AppError, String>> saveImage(String url) async {
    final response = (await safe(http.get(url))).then(checkHttpStatus);
    return response.asyncThen<String>((right) async {
      final filename = await _getImagePath(url);
      try {
        await _cache.cachedImagesDao.insertImage(CachedImage(url: url, path: filename));
        final file = File(filename);
        await file.writeAsBytes(right.bodyBytes);
        return Right(filename);
      } catch (err) {
        return Left(AppError(errCode: ErrorType.NotCached, message: "img url exist in cache"));
      }
    });
  }

  Future deleteImage(String url) async {
    // картинка не удалится из кеша тк путь будет не тот,
    // путь нужно брать из бд
    final optionalImage = await getImage(url);
    if (optionalImage.isLeft) return;
    final path = optionalImage.right;
    await _cache.cachedImagesDao.deleteImage(url);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Either<AppError, String>> getImage(String url) async {
    final res = await _cache.cachedImagesDao.getImage(url);
    return Either.condLazy(
        res != null,
        () => const AppError(
            errCode: ErrorType.NotFound, message: "Image in cache not found"),
        () => res.path);
  }
}
