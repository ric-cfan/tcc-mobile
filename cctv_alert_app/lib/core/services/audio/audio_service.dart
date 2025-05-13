import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAlarm() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/alarm.mp3'), volume: 1.0);
  }

  static Future<void> stopAlarm() async {
    await _player.stop();
  }
}
