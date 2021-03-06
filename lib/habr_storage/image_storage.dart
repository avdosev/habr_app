import 'package:either_dart/either.dart';

import 'package:habr_app/app_error.dart';
import 'package:habr_app/utils/workers/hasher.dart';
import 'package:habr_app/utils/workers/image_loader.dart';
import 'package:habr_app/utils/http_request_helper.dart';
import 'package:habr_app/utils/log.dart';
import 'cache_tables.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageLocalStorage {
  final Cache _cache;
  final HashComputer _hashComputer;
  final ImageLoader _imageLoader;
  String _path;

  ImageLocalStorage(this._cache, this._hashComputer, this._imageLoader);

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

  Future<String> _generateImageName(String url) async {
    final prefix1 = await _hashComputer.hash(url);
    final prefix2 = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    String postfix = url.split('.').last;
    postfix = postfix.length > 8 ? 'none' : postfix;
    return '${prefix1}_$prefix2.$postfix';
  }

  /// Return AppError or path to saved file
  Future<Either<AppError, String>> saveImage(String url) async {
    final maybeImage = await _cache.cachedImagesDao.getImage(url);
    if (maybeImage != null) {
      return Right(maybeImage.path);
    }

    final filename = await _getImagePath(url);
    logInfo('Saving image to $filename');
    final loaded = await _imageLoader.loadImage(url, filename);

    if (!loaded) {
      return Left(AppError(
        errCode: ErrorType.NotCached,
        message: 'img not loaded',
      ));
    }

    try {
      await _cache.cachedImagesDao
          .insertImage(CachedImage(url: url, path: filename));
    } catch (err) {
      logError(err);
      // пока изображение грузилось
      // оно загрузилось несколько раз
      // повторный файл не нужен, поэтому его можно удалить
      File(filename).delete();
      return Left(AppError(
        errCode: ErrorType.NotCached,
        message: "img url exist in cache",
      ));
    }

    return Right(filename);
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
      logInfo("Изображение удалено path:$path");
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
