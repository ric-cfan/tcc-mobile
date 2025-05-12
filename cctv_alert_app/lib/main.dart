import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'core/services/notifications_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Image Viewer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: FutureBuilder(
        future: NotificationsService.init((payload) {
          // Não faz nada aqui por enquanto, pois vamos utilizar a payload depois na HomeScreen
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Exibe uma tela de carregamento enquanto espera pela inicialização
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Exibe erro se acontecer durante a inicialização
            return Center(child: Text('Erro ao inicializar notificações: ${snapshot.error}'));
          } else {
            // Quando as notificações estiverem inicializadas, podemos mostrar a HomeScreen
            return const HomeScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
