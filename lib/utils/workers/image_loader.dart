import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:habr_app/utils/http_request_helper.dart';
import 'package:habr_app/utils/log.dart';

import 'package:habr_app/utils/worker/worker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../app_error.dart';

abstract class ImageLoader {
  Future<bool> loadImage(String url, String path);
}

class _ArgObj {
  final String url;
  final String path;

  _ArgObj(this.url, this.path);
}

class ImageHttpLoader implements ImageLoader {
  final _worker = Worker(name: 'image loader');

  @override
  Future<bool> loadImage(String url, String path) async {
    return _worker.work(Runnable(fun: _loadImage, arg: _ArgObj(url, path)));
  }

  static Future<bool> _loadImage(_ArgObj args) async {
    try {
      final response = await http.get(Uri.parse(args.url));

      if (checkHttpStatus(response).isLeft) {
        return false;
      }

      final file = File(args.path);
      final image = response.bodyBytes;
      await file.writeAsBytes(image);

    } catch (err) {
      logError("loading image by url:${args.url} ended with err: $err");
      return false;
    }

    return true;
  }

  void dispose() {
    _worker.kill();
  }
}
