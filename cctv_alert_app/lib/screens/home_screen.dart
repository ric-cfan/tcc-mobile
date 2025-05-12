import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/websocket_manager.dart';
import '../core/image_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WebSocketManager? _webSocketManager;
  String _imageBase64 = '';
  String _status = 'Desconectado';
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  final String _url = 'ws://localhost:8000/ws';

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    setState(() {
      _status = 'Conectando...';
    });

    try {
      _webSocketManager = WebSocketManager(WebSocketChannel.connect(Uri.parse(_url)));
      _subscription = _webSocketManager!.listen().listen(
        (message) {
          setState(() {
            _imageBase64 = message;
            _status = 'Conectado';
          });
        },
        onDone: _handleDisconnection,
        onError: (error) {
          _handleDisconnection();
        },
      );
    } catch (_) {
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    setState(() {
      _status = 'Desconectado. Tentando reconectar...';
    });

    _subscription?.cancel();
    _webSocketManager?.close();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _connectWebSocket();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _webSocketManager?.close();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Image Viewer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Status: $_status',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _imageBase64.isEmpty
                  ? const Text('Esperando imagem...')
                  : ImageDisplay(base64Image: _imageBase64),
            ),
          ),
        ],
      ),
    );
  }
}
