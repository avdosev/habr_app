import 'dart:async';
import 'dart:isolate';

import 'package:habr_app/utils/log.dart';

import 'id_generator.dart';

import 'runnable.dart';
export 'runnable.dart';

class Worker {
  Isolate? _isolate;
  late ReceivePort _receivePort;
  SendPort? _sendPort;
  StreamSubscription<dynamic>? _portSub;
  final String name;
  Completer<void>? initCompleter;

  final _results = Map<int, Completer<dynamic>>();
  final _idGen = IdGenerator();

  Worker({required this.name});

  Future<void> initialize() async {
    final initializationBeenStarted =
        initCompleter != null && !initCompleter!.isCompleted;

    if (initializationBeenStarted) {
      await initCompleter!.future;
      return;
    }

    logInfo('create isolate: $name');
    initCompleter = Completer<void>();
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_anotherIsolate, _receivePort.sendPort);

    _portSub = _receivePort.listen((message) {
      if (message is ResultMessage) {
        _results[message.taskId]?.complete(message.result);
        _results.remove(message.taskId);
      } else if (message is ErrorMessage) {
        _results[message.taskId]?.completeError(
          message.error,
          message.stackTrace,
        );
        _results.remove(message.taskId);
      } else {
        _sendPort = message;
        initCompleter!.complete();
      }
    });
    await initCompleter!.future;
  }

  Future<OutT> work<ArgT, OutT>(Runnable<ArgT, OutT> task) async {
    if (notStarted) {
      await initialize();
    }
    final completer = Completer<OutT>();
    final taskId = _idGen.genId();
    _results[taskId] = completer;
    _sendPort?.send(WorkMessage(taskId: taskId, runnable: task));
    return completer.future;
  }

  static void _anotherIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) async {
      if (message is WorkMessage) {
        final taskId = message.taskId;
        try {
          final result = await message.runnable.call();
          sendPort.send(ResultMessage(taskId: taskId, result: result));
        } catch (error) {
          try {
            sendPort.send(ErrorMessage(error, taskId: taskId));
          } catch (error) {
            sendPort.send(ErrorMessage(
                'can`t send error with too big stackTrace, error is : ${error.toString()}',
                taskId: taskId));
          }
        }
      }
    });
  }

  bool get started => initCompleter != null && initCompleter!.isCompleted;

  bool get notStarted => !started;

  Future<void> kill() async {
    initCompleter = null;
    final cancelableIsolate = _isolate;
    _isolate = null;
    await _portSub?.cancel();
    _sendPort = null;
    cancelableIsolate?.kill(priority: Isolate.immediate);
  }
}

class WorkMessage {
  final int taskId;
  final Runnable runnable;

  WorkMessage({
    required this.runnable,
    required this.taskId,
  });
}

class ResultMessage {
  final int taskId;
  final Object? result;

  ResultMessage({required this.result, required this.taskId});
}

class ErrorMessage {
  final int taskId;
  final Object error;
  final StackTrace? stackTrace;

  ErrorMessage(this.error, {this.stackTrace, required this.taskId});
}
