import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/image_display.dart';
import '../core/services/background_socket.dart';
import '../core/services/notifications_service.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final List<BackgroundSocket> _sockets = [];
  String _imageBase64 = '';
  String _date = '';
  String _time = '';
  String _timezone = '';
  String _camera = '';
  String _status = 'Desconectado';
  bool _isAlarmPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    NotificationsService.setOnNotificationClick(() {
      setState(() => _isAlarmPlaying = false);
    });

    _initializeSockets();
  }

  Future<void> _initializeSockets() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/cameras'));
        if (response.statusCode == 200) {
          final Map<String, dynamic> body = json.decode(response.body);
          final List<dynamic> cameras = body['cameras'];

        for (final camera in cameras) {
          final socket = BackgroundSocket();
          _sockets.add(socket);

          socket.start('ws://localhost:8000/ws/$camera', (message) async {
            try {
              final data = json.decode(message);
              final base64 = data['image_base64'];
              final date = data['date'];
              final time = data['time'];
              final timezone = data['timezone'];
              final cameraId = data['camera'];

              await NotificationsService.show(base64);

              setState(() {
                _imageBase64 = base64;
                _date = date;
                _time = time;
                _timezone = timezone;
                _camera = cameraId ?? camera.toString();
                _status = 'Conectado';
                _isAlarmPlaying = true;
              });
            } catch (_) {
              setState(() => _status = 'Erro ao decodificar JSON');
            }
          });
        }
      } else {
        setState(() => _status = 'Erro ao obter lista de câmeras');
      }
    } catch (e) {
      setState(() => _status = 'Falha na requisição HTTP: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final socket in _sockets) {
      socket.stop();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Não utilizado diretamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Image Viewer')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Status: $_status',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_date.isNotEmpty && _time.isNotEmpty) ...[
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
                setState(() => _isAlarmPlaying = false);
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
