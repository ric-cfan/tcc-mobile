import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init(Function(String?) onSelectNotification) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onSelectNotification(response.payload);
      },
    );
  }

  static Future<void> show(String base64Image) async {
    const android = AndroidNotificationDetails(
      'channel_id',
      'Camera Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: android);

    await _notifications.show(
      0,
      'Pessoa detectada',
      'Toque para ver a imagem',
      notificationDetails,
      payload: base64Image,
    );
  }
}
