import 'dart:collection';

import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import '../log.dart';

String _computeMD5Hash(String str) {
  return md5.convert(utf8.encode(str)).toString();
}

abstract class HashComputer {
  Future<String> hash(String str);
}

class MD5Hash extends HashComputer {
  Isolate _isolate;
  SendPort _sendPort;
  ReceivePort _receivePort;
  final Queue<Completer<String>> tasks = Queue();
  Completer<void> _creatingIsolate;

  @override
  Future<String> hash(String str) async {
    final completer = Completer<String>();
    await _compute(str, completer);
    return completer.future;
  }

  Future<void> _compute(String data, Completer<String> completer) async {
    if (_sendPort == null) {
      // Создается изолят
      // Необходимость подобного - нет смысла создавать изолят
      // если приложение не считает хеши
      if (_creatingIsolate == null) {
        _creatingIsolate = Completer();
        _createIsolate(_creatingIsolate);
      }
      await _creatingIsolate.future;

      assert(_sendPort != null, "Send port must be not null");
    }

    tasks.addLast(completer);
    _sendPort.send(data);
  }

  void _createIsolate(Completer completer) async {
    logInfo("Create isolate: md5_hasher");
    _receivePort = ReceivePort();

    // Экземпляр нового Изолята
    _isolate = await Isolate.spawn(
      _hashComputer,
      _receivePort.sendPort,
      debugName: "md5_hasher",
    );

    _receivePort.listen((message) {
      if (message is SendPort) {
        // Извлечение нового порта для общения
        _sendPort = message;
        completer.complete();
      } else if (message is String) {
        // Обработка полученных результатов
        tasks.first.complete(message);
        tasks.removeFirst();
      }
    });
  }

  // Точка входа нового Изолята
  static void _hashComputer(SendPort sendPort) {
    // Инстанцирует отправляющий порт для приема сообщения
    ReceivePort receivePort = ReceivePort();

    // Предоставляет ссылку на SandPort новых Изолятов
    sendPort.send(receivePort.sendPort);

    // Обработка
    receivePort.listen((message) {
      final str = message as String;
      sendPort.send(_computeMD5Hash(str));
    });
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
  }
}
