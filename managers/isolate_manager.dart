import 'package:shop_helper_flutter/managers/pdf_manager.dart';
import 'package:shop_helper_flutter/providers/main_provider.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:isolate';


// Isolate is needed because pdf file generation locks ui
class IsolateManager {
  SendPort newIsolateSendPort;
  FlutterIsolate newIsolate;

  Future<List<int>> sendPdf() async {
    try {
      await _callerCreateIsolate();
      final bytes = await _sendRecieve();
      _dispose();
      return bytes;
    } catch (e) {
      print("EXCEPTION: $e");
      return [];
    }
  }

  // thread creation
  Future<void> _callerCreateIsolate() async {
    ReceivePort receivePort = ReceivePort();
    newIsolate =
        await FlutterIsolate.spawn(_isolateFunction, receivePort.sendPort);
    newIsolateSendPort = await receivePort.first;
  }

  // exchange data between isolates
  Future<List<int>> _sendRecieve() async {
    final port = ReceivePort();
    newIsolateSendPort.send({
      'sender': port.sendPort,
      'message': MainProvider().purchasesList,
    });
    final bytes = (await port.first) as List<int>;
    return bytes;
  }

  // executed in separate thread
  static void _isolateFunction(SendPort sendPort) {
    ReceivePort newIsolateReceivePort = ReceivePort();
    sendPort.send(newIsolateReceivePort.sendPort);
    newIsolateReceivePort.listen((message) async {
      final bytes = await PDFManager().sendPDF(message['message']);
      final sendPort = message['sender'] as SendPort;
      sendPort.send(bytes);
    });
  }

  void _dispose() {
    newIsolate.kill();
  }
}
