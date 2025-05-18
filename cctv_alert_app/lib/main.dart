import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/notifications_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeApp() async {
    // Solicita permissão para notificações no Android 13+
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      throw Exception('Permissão de notificação não concedida');
    }

    // Inicializa o serviço de notificações
    await NotificationsService.init((payload) {
      if (payload != null) {
        // Aqui você pode navegar para uma tela com a imagem
        // Exemplo: Navigator.push(...) passando o base64 da imagem
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Image Viewer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Erro ao inicializar: ${snapshot.error}')),
            );
          } else {
            return const HomeScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
