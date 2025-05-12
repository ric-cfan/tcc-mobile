import 'package:flutter/material.dart';
import '../core/image_display.dart';
import '../core/services/background_socket.dart';
import '../core/services/notifications_service.dart';

class HomeScreen extends StatefulWidget {
  final String? initialImageBase64; 

  const HomeScreen({super.key, this.initialImageBase64});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BackgroundSocket _backgroundSocket;
  String _imageBase64 = '';
  String _status = 'Desconectado';

  @override
  void initState() {
    super.initState();
    _backgroundSocket = BackgroundSocket();
    _backgroundSocket.start('ws://localhost:8000/ws', (message) {
      setState(() {
        _imageBase64 = message;
        _status = 'Conectado';
      });

      // Exibe a notificação com a imagem
      NotificationsService.show(message);
    });

    // Verifica se a imagem inicial foi recebida
    if (widget.initialImageBase64 != null && widget.initialImageBase64!.isNotEmpty) {
      _imageBase64 = widget.initialImageBase64!;
    }
  }

  @override
  void dispose() {
    _backgroundSocket.stop();
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
