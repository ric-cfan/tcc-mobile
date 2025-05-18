import 'dart:convert';
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
  String _date = '';
  String _time = '';
  String _timezone = '';
  String _camera = '';
  String _status = 'Desconectado';
  bool _isInForeground = true;
  bool _isAlarmPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Passa o callback para o NotificationsService para esconder botão ao clicar na notificação
    NotificationsService.setOnNotificationClick(() {
      setState(() {
        _isAlarmPlaying = false;
      });
    });

    _backgroundSocket = BackgroundSocket();
    _backgroundSocket.start('ws://localhost:8000/ws', (message) async {
      try {
        final data = json.decode(message);
        final base64 = data['image_base64'];
        final date = data['date'];
        final time = data['time'];
        final timezone = data['timezone'];
        final camera = data['camera'];

        // Mostra notificação e toca alarme
        await NotificationsService.show(base64);

        setState(() {
          _imageBase64 = base64;
          _date = date;
          _time = time;
          _timezone = timezone;
          _camera = camera ?? '';
          _status = 'Conectado';
          _isAlarmPlaying = true;
        });
      } catch (e) {
        setState(() => _status = 'Erro ao decodificar JSON');
      }
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
          if (_date.isNotEmpty && _time.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Data: $_date'),
            Text('Hora: $_time'),
            Text('Fuso horário: $_timezone'),
            Text('Câmera: $_camera'),
          ],
          const SizedBox(height: 20),
          if (_isAlarmPlaying)
            ElevatedButton(
              onPressed: () async {
                await NotificationsService.cancel();
                setState(() {
                  _isAlarmPlaying = false;
                });
              },
              child: const Text('Parar Alarme'),
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
