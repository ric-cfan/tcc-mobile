import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static late String base64Image;

  static Future<void> init(Function(String?) onSelectNotification) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(
      android: android,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onSelectNotification(response.payload);
        if (response.payload != null) {
          // Quando a notificação for clicada ou o botão "Silenciar" for pressionado,
          // cancela o som
          stopSound();
        }
      },
    );
  }

  static Future<void> show(String base64ImageParam) async {
    base64Image = base64ImageParam; // Guardando a imagem para referência futura

    final android = AndroidNotificationDetails(
      'channel_id',
      'Camera Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'), // Alarme em loop
      enableVibration: true,
      additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT
      ticker: 'Pessoa detectada', // Adiciona texto explicativo na notificação
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'silenciar', // Identificador da ação
          'Silenciar', // Texto do botão
          //icon: 'ic_silenciar', // Ícone opcional para o botão
        )
      ],
    );

    final notificationDetails = NotificationDetails(android: android);

    await _notifications.show(
      0,
      'Pessoa detectada',
      'Toque para ver a imagem',
      notificationDetails,
      payload: base64Image,
    );
  }

  static Future<void> stopSound() async {
    // Cancela a notificação, parando o som
    await _notifications.cancel(0); // Cancela a notificação e para o som
  }

  static Future<void> handleSilenceAction() async {
    // Esse método é chamado quando o botão "Silenciar" é clicado
    stopSound(); // Parando o som ao silenciar
  }
}
