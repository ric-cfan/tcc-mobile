import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static AudioPlayer? _audioPlayer;
  static bool _isPlaying = false;

  // Variável para armazenar callback
  static Function()? _onNotificationClick;

  static Future<void> init(Function(String?) onSelectNotification) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _stopAlarm();
        if (_onNotificationClick != null) {
          _onNotificationClick!();
        }
        onSelectNotification(response.payload);
      },
    );
  }

  // Setter para callback
  static void setOnNotificationClick(Function() callback) {
    _onNotificationClick = callback;
  }

  static Future<void> _playAlarm() async {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.setVolume(1.0);
    }

    if (!_isPlaying) {
      try {
        await _audioPlayer!.play(AssetSource('alarm.mp3'));
        _isPlaying = true;
      } catch (e) {
        print('Erro ao tocar som: $e');
      }
    }
  }

  static Future<void> _stopAlarm() async {
    if (_audioPlayer != null && _isPlaying) {
      try {
        await _audioPlayer!.stop();
        await _audioPlayer!.release();
      } catch (e) {
        print('Erro ao parar som: $e');
      }
      _audioPlayer = null;
      _isPlaying = false;
    }
  }

  static Future<void> show(String base64Image) async {
    await _playAlarm();

    const android = AndroidNotificationDetails(
      'alert_channel',
      'Camera Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      enableLights: true,
      ticker: 'Pessoa detectada',
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

  static Future<void> cancel() async {
    await _stopAlarm();
    await _notifications.cancelAll();
  }
}
