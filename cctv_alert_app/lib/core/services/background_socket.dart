import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../websocket_manager.dart';

class BackgroundSocket {
  late WebSocketManager _webSocketManager;
  StreamSubscription? _subscription;
  String _status = 'Desconectado';

  void start(String url, Function(String message) onMessageReceived) {
    _connect(url, onMessageReceived);
  }

  void _connect(String url, Function(String message) onMessageReceived) {
    try {
      _status = 'Conectando...';
      _webSocketManager = WebSocketManager(WebSocketChannel.connect(Uri.parse(url)));

      _subscription = _webSocketManager.listen().listen((message) {
        _status = 'Conectado';
        onMessageReceived(message);  // Passando a imagem para quem chamou
      }, onDone: _handleDisconnection, onError: (error, stackTrace) {
        _handleDisconnection();
        // Log or handle the error and stack trace here if needed
        print("WebSocket error: $error");
        print("Stack trace: $stackTrace");
      });
    } catch (_) {
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _status = 'Desconectado. Tentando reconectar...';
    _webSocketManager.reconnect('ws://localhost:8000/ws', () {
      _connect('ws://localhost:8000/ws', (message) {});
    });
  }

  void stop() {
    _subscription?.cancel();
    _webSocketManager.close();
  }

  String get status => _status;
}
