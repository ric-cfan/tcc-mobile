import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../websocket_manager.dart';

class BackgroundSocket {
  late WebSocketManager _webSocketManager;
  StreamSubscription? _subscription;
  String _status = 'Desconectado';
  late String _url;
  late Function(String message) _onMessageReceived;

  void start(String url, Function(String message) onMessageReceived) {
    _url = url;
    _onMessageReceived = onMessageReceived;
    _connect();
  }

  void _connect() {
    try {
      _status = 'Conectando...';
      _webSocketManager = WebSocketManager(WebSocketChannel.connect(Uri.parse(_url)));

      _subscription = _webSocketManager.listen().listen((message) {
        _status = 'Conectado';
        _onMessageReceived(message);
      }, onDone: _handleDisconnection, onError: (error, stackTrace) {
        _handleDisconnection();
      });
    } catch (_) {
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _status = 'Desconectado. Tentando reconectar...';
    _webSocketManager.reconnect(_url, () {
      _connect();
    });
  }

  void stop() {
    _subscription?.cancel();
    _webSocketManager.close();
  }

  String get status => _status;
}
