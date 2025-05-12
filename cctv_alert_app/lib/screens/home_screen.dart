import 'package:flutter/material.dart';
import '../core/image_display.dart';
import '../core/services/background_socket.dart';
import '../core/services/notifications_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late BackgroundSocket _backgroundSocket;
  String _imageBase64 = '';
  String _status = 'Desconectado';
  bool _isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _backgroundSocket = BackgroundSocket();
    _backgroundSocket.start('ws://localhost:8000/ws', (message) async {
      if (!_isInForeground) {
        await NotificationsService.show(message);
      }
      setState(() {
        _imageBase64 = message;
        _status = 'Conectado';
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundSocket.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isInForeground = state == AppLifecycleState.resumed;
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
