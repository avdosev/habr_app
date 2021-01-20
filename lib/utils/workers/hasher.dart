import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';

import 'package:habr_app/utils/log.dart';

import 'package:habr_app/utils/worker/worker.dart';

String _computeMD5Hash(String str) {
  return md5.convert(utf8.encode(str)).toString();
}

abstract class HashComputer {
  Future<String> hash(String str);
}

class MD5Hash implements HashComputer {
  final _worker = Worker(name: 'md5 hash');

  @override
  Future<String> hash(String str) async {
    return _worker.work(Runnable(fun: _computeMD5Hash, arg: str));
  }

  void dispose() {
    _worker.kill();
  }
}
