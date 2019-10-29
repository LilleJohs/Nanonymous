import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:package_info/package_info.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketConnection {
  final String url = 'ws://206.189.115.252:5000';
  final StreamSink<Map<String, dynamic>> _walletSink;

  WebSocketChannel _wsChannel;
  WebSocketChannel get wsChannel => _wsChannel;
  bool connected = false;

  WebSocketConnection(this._walletSink) {
    connectingToWebSocket();
  }

  Future<bool> connectingToWebSocket() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      _wsChannel = IOWebSocketChannel(await WebSocket.connect(url));
      _wsChannel.stream.listen(
        (message) {
          readMessage(message);
        },
        onDone: disconnectedFromWebSocket,
        onError: (error) => disconnectedFromWebSocket(),
      );
      connected = true;
      _wsChannel.sink.add(json.encode({
        'title': 'VERSION_NUMBER',
        'versionNumber': packageInfo.buildNumber
      }));
      _walletSink.add({'title': 'FIRST_TIME_CONNECTED'});
      return connected;
    } catch (e) {
      print('Unable to connect to websocket');
      print(e.toString());
      disconnectedFromWebSocket();
      return false;
    }
  }

  void readMessage(String message) {
    final jsonMessage = json.decode(message);
    _walletSink.add(jsonMessage);
  }

  void disconnectedFromWebSocket() {
    print('Disconnected');
    connected = false;
    // Trying to reconnect
    Future.delayed(Duration(seconds: 3), () {
      print('Trying to reconnect');
      connectingToWebSocket();
    });
  }
}
